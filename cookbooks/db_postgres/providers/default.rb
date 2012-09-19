#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include RightScale::Database::Helper
include RightScale::Database::PostgreSQL::Helper

action :stop do
  @db = init(new_resource)
  @db.stop
end

action :start do
  @db = init(new_resource)
  @db.start
end

action :status do
  @db = init(new_resource)
  status = @db.status
  log "Database Status:\n#{status}"
end

action :lock do
  @db = init(new_resource)
  @db.lock
end

action :unlock do
  @db = init(new_resource)
  @db.unlock
end

action :move_data_dir do
  @db = init(new_resource)
  @db.move_datadir(new_resource.name, node[:db_postgres][:datadir])
end

action :reset do
  @db = init(new_resource)
  @db.reset(new_resource.name, node[:db_postgres][:datadir])
end

action :firewall_update_request do
  sys_firewall "Request database open port 5432 (PostgreSQL) to this server" do
    machine_tag new_resource.machine_tag
    port 5432
    enable new_resource.enable
    ip_addr new_resource.ip_addr
    action :update_request
  end
end

action :firewall_update do
  sys_firewall "Request database open port 5432 (PostgrSQL) to this server" do
    machine_tag new_resource.machine_tag
    port 5432
    enable new_resource.enable
    action :update
  end
end

action :write_backup_info do
  db_state_get node
  File_position = `#{node[:db_postgres][:bindir]}/pg_controldata #{node[:db_postgres][:datadir]} | grep "Latest checkpoint location:" | awk '{print $NF}'`
  masterstatus = Hash.new
  masterstatus['Master_IP'] = node[:db][:current_master_ip]
  masterstatus['Master_instance_uuid'] = node[:db][:current_master_uuid]
  slavestatus ||= Hash.new
  slavestatus['File_position'] = File_position
  if node[:db][:this_is_master]
    log "  Backing up Master info"
  else
    log "  Backing up slave replication status"
    masterstatus['File_position'] = slavestatus['File_position']
  end
  log "  Saving master info...:\n#{masterstatus.to_yaml}"
  ::File.open(::File.join(node[:db][:data_dir], RightScale::Database::PostgreSQL::Helper::SNAPSHOT_POSITION_FILENAME), ::File::CREAT|::File::TRUNC|::File::RDWR) do |out|
    YAML.dump(masterstatus, out)
  end
end

action :pre_restore_check do
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

action :post_restore_cleanup do
  @db = init(new_resource)
  @db.restore_snapshot
end

action :pre_backup_check do
  @db = init(new_resource)
  @db.pre_backup_check
end

action :post_backup_cleanup do
  @db = init(new_resource)
  @db.post_backup_steps
end

action :set_privileges do
  if ::File.exist?("#{node[:db_postgres][:datadir]}/recovery.conf")
    log "  No need to rerun on reboot for slave"
  else
    priv = new_resource.privilege
    priv_username = new_resource.privilege_username
    priv_password = new_resource.privilege_password
    priv_database = new_resource.privilege_database
    db_postgres_set_privileges "setup db privileges" do
      preset priv
      username priv_username
      password priv_password
      database priv_database
    end
  end
end

action :install_client do

  # Install PostgreSQL package(s)

  node[:db][:socket] = value_for_platform(
    "centos" => {
      "default" => "/var/run/postgresql"
    },
    "default" => ""
  )

  node[:db_postgres][:client_packages_install] = value_for_platform(
    "centos" => {
      "default" => [
        "postgresql91-libs",
        "postgresql91",
        "postgresql91-devel"
      ]
    },
    "default" => []
  )

  node[:db_postgres][:packages_version] = value_for_platform(
    "centos" => {
      "5.8" => "9.1.5-3PGDG.rhel5",
      "default" => "9.1.5-3PGDG.rhel6"
    },
    "default" => ""
  )

  raise "Platform not supported for PostgreSQL #{version}" if node[:db_postgres][:client_packages_install].empty?

  # Install PostgreSQL package(s)
  if node[:platform] == "centos"
    arch = node[:kernel][:machine]
    raise "Unsupported platform detected!" unless arch == "x86_64"

    package "libxslt" do
      action :install
    end

    packages = node[:db_postgres][:client_packages_install]
    log  "Packages to install: #{packages.join(", ")}"
    packages.each do |p|
      package p do
        action :install
        version node[:db_postgres][:packages_version]
      end
    end
  else
    # Currently supports CentOS in future will support others
    raise "ERROR:: Unrecognized distro #{node[:platform]}, exiting "
  end

  # Link postgresql pg_config to default system bin path - required by app servers
  link "/usr/bin/pg_config" do
    to "/usr/pgsql-#{node[:db_postgres][:version]}/bin/pg_config"
    not_if { ::File.exists?("/usr/bin/pg_config") }
  end

  # Install PostgreSQL client gem
  gem_package("pg") do
    gem_binary("/opt/rightscale/sandbox/bin/gem")
    options("-- --with-pg-config=#{node[:db_postgres][:bindir]}/pg_config")
  end
end

action :install_server do

  arch = node[:kernel][:machine]
  raise "Unsupported platform detected!" unless arch == "x86_64"

  package "uuid" do
    action :install
  end

  packages = node[:db_postgres][:server_packages_install]
  log "  Packages to install: #{packages.join(",")}"
  packages.each do |p|
    package p do
      action :install
      version node[:db_postgres][:packages_version]
    end
  end

  service "postgresql-#{node[:db_postgres][:version]}" do
    supports :status => true, :restart => true, :reload => true
    action :stop
  end

  # Initialize PostgreSQL server and create system tables
  touchfile = ::File.expand_path "~/.postgresql_installed"
  execute "/etc/init.d/postgresql-#{node[:db_postgres][:version]} initdb ; touch #{touchfile}" do
    creates touchfile
    not_if "test -f #{touchfile}"
  end

  # Configure system for PostgreSQL
  #
  # Stop PostgreSQL
  service "postgresql-#{node[:db_postgres][:version]}" do
    action :stop
  end


  # Create the Socket directory
  #directory "/var/run/postgresql" do
  directory "#{node[:db][:socket]}" do
    owner "postgres"
    group "postgres"
    mode 0770
    recursive true
  end

  # Setup postgresql.conf
  # template_source = "postgresql.conf.erb"
  configfile = ::File.expand_path "~/.postgresql_config.done"
  template "#{node[:db_postgres][:confdir]}/postgresql.conf" do
    source "postgresql.conf.erb"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook 'db_postgres'
    not_if "test -f #{configfile}"
  end

  # Setup pg_hba.conf
  # pg_hba_source = "pg_hba.conf.erb"
  cookbook_file ::File.join(node[:db_postgres][:confdir], 'pg_hba.conf') do
    source "pg_hba.conf"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook 'db_postgres'
    not_if "test -f #{configfile}"
  end

  execute "touch #{configfile}" do
    creates configfile
  end

  # Setup PostgreSQL user limits
  #
  # Set the postgres and root users max open files to a really large number.
  # 1/3 of the overall system file max should be large enough.  The percentage can be
  # adjusted if necessary.
  postgres_file_ulimit = node[:db_postgres][:tunable][:ulimit]

  template "/etc/security/limits.d/postgres.limits.conf" do
    source "postgres.limits.conf.erb"
    variables({
      :ulimit => postgres_file_ulimit
    })
    cookbook 'db_postgres'
  end

  # Change root's limitations for THIS shell.  The entry in the limits.d will be
  # used for future logins.
  # The setting needs to be in place before postgresql-9 is started.
  execute "ulimit -n #{postgres_file_ulimit}"

  # Start PostgreSQL
  service "postgresql-#{node[:db_postgres][:version]}" do
    action :start
  end

end

action :grant_replication_slave do
  require 'rubygems'
  Gem.clear_paths
  require 'pg'



  # Opening connection for pg operation
  conn = PGconn.open("localhost", nil, nil, nil, nil, "postgres", nil)

  # Now that we have a Postgresql object, let's sanitize our inputs. These will get pass for log and comparison.
  username_esc = conn.escape_string(node[:db][:replication][:user])
  password_esc = conn.escape_string(node[:db][:replication][:password])
  # Following Username and password will get to pass for creation of user.
  username = conn.quote_ident(username_esc)
  password = conn.quote_ident(password_esc)
  log "  GRANT REPLICATION SLAVE to user #{username}"

  # Enable admin/replication user
  # Check if server is in read_only mode, if found skip this...
  res = conn.exec("show transaction_read_only")
  slavestatus = res.getvalue(0,0)
  if ( slavestatus == 'off' )
    log "  Detected Master server."
    result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
    userstat = result.getvalue(0,0)
    if ( userstat == '1' )
      log "  User #{username} already exists, updating user using current inputs"
      conn.exec("ALTER USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
    else
      log "  Creating replication user #{username}"
      conn.exec("CREATE USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
      # Setup pg_hba.conf for replication user allow
      RightScale::Database::PostgreSQL::Helper.configure_pg_hba(node)
      # Reload postgresql to read new updated pg_hba.conf
      RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')
    end
  else
    log "  Do nothing, Detected read_only db or slave mode"
  end
  conn.finish
end


action :enable_replication do
  db_state_get node
  current_restore_process = new_resource.restore_process

  newmaster_host = node[:db][:current_master_ip]
  rep_user = node[:db][:replication][:user]
  rep_pass = node[:db][:replication][:password]
  app_name = node[:rightscale][:instance_uuid]

  # Check the volume before performing any actions.  If invalid raise error and exit.
  ruby_block "validate_master" do
    not_if { current_restore_process == :no_restore }
    block do
      master_info = RightScale::Database::PostgreSQL::Helper.load_replication_info(node)

      # Check that the snapshot is from the current master or a slave associated with the current master
      raise "Position and file not saved or it does not contain info!" unless master_info['Master_instance_uuid']
      raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_uuid']} != current master: #{node[:db][:current_master_uuid]}" unless master_info['Master_instance_uuid'] == node[:db][:current_master_uuid]
    end
  end

  # Stopping Postgresql service
  service "postgresql-#{node[:db_postgres][:version]}" do
    not_if { current_restore_process == :no_restore }
    action :stop
  end

  ruby_block "Sync to Master data" do
    not_if { current_restore_process == :no_restore }
    block do
      RightScale::Database::PostgreSQL::Helper.rsync_db(newmaster_host, rep_user)
    end
  end

  ruby_block "configure_replication" do
    not_if { current_restore_process == :no_restore }
    block do
      master_info = RightScale::Database::PostgreSQL::Helper.load_replication_info(node)
      newmaster_host = master_info['Master_IP']
      RightScale::Database::PostgreSQL::Helper.reconfigure_replication_info(newmaster_host, rep_user, rep_pass, app_name)
    end
  end

  bash "wipe_existing_runtime_config" do
    not_if { current_restore_process == :no_restore }
    flags "-ex"
     code <<-EOH
       rm -rf #{node[:db_postgres][:datadir]}/pg_xlog/*
     EOH
  end

  # Ensure that database started
  # service provider uses the status command to decide if it
  # has to run the start command again.
  ruby_block "Start Postgresql service" do
    block do
      retries 5
      retry_delay 2
      action_start
    end
  end

  # Setup slave monitoring
  action_setup_slave_monitoring
end  

action :promote do
  db_state_get node

  previous_master = node[:db][:current_master_ip]
  raise "FATAL: could not determine master host from slave status" if previous_master.nil?
  log "  host: #{previous_master}}"

  begin
    # Promote the slave into the new master
    Chef::Log.info "  Promoting slave.."
    RightScale::Database::PostgreSQL::Helper.write_trigger(node)
    sleep 10

    # Let the new slave loose and thus let him become the new master
    Chef::Log.info  "  New master is ReadWrite."

  rescue => e
    Chef::Log.info "  WARNING: caught exception #{e} during critical operations on the MASTER"
  end
end

action :setup_monitoring do
  db_state_get node

  priv_username = new_resource.privilege_username
  priv_password = new_resource.privilege_password

  service "collectd" do
    action :nothing
  end

  if node[:platform] == 'centos'

    collectd_version = node[:rightscale][:collectd_packages_version]
    package "collectd-postgresql" do
      action :install
      version "#{collectd_version}" unless collectd_version == "latest"
    end

    template ::File.join(node[:rightscale][:collectd_plugin_dir], 'postgresql.conf') do
      backup false
      source "postgresql_collectd_plugin.conf.erb"
      variables(
        :database_owner => priv_username,
        :database_owner_pass => priv_password
      )
      notifies :restart, resources(:service => "collectd")
      cookbook 'db_postgres'
    end

    template ::File.join(node[:rightscale][:collectd_share], 'postgresql_default.conf') do
      backup false
      source "postgresql_default.conf.erb"
      notifies :restart, resources(:service => "collectd")
      cookbook 'db_postgres'
    end

    # Install the postgres_ps collectd script into the collectd library plugins directory
    cookbook_file ::File.join(node[:rightscale][:collectd_lib], "plugins", 'postgres_ps') do
      source "postgres_ps"
      mode "0755"
      cookbook 'db_postgres'
    end

    # Add a collectd config file for the postgres_ps script with the exec plugin and restart collectd if necessary
    template ::File.join(node[:rightscale][:collectd_plugin_dir], 'postgres_ps.conf') do
      source "postgres_collectd_exec.erb"
      notifies :restart, resources(:service => "collectd")
      cookbook 'db_postgres'
    end

  else

    log "  WARNING: attempting to install collectd-postgresql on unsupported platform #{node[:platform]}, continuing.." do
      level :warn
    end

  end
end

action :setup_slave_monitoring do
  db_state_get node

  service "collectd" do
    action :nothing
  end

  # Now setup monitoring for slave replication, hard to define the lag, we are trying to get master/slave sync health status

  # Install the pg_cluster_status collectd script into the collectd library plugins directory
  cookbook_file ::File.join(node[:rightscale][:collectd_lib], "plugins", 'pg_cluster_status') do
    source "pg_cluster_status"
    mode "0755"
    cookbook 'db_postgres'
  end

  # Add a collectd config file for the pg_cluster_status script with the exec plugin and restart collectd if necessary
  template ::File.join(node[:rightscale][:collectd_plugin_dir], 'pg_cluster_status.conf') do
    source "pg_cluster_status_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook 'db_postgres'
  end

  # Install the check_hot_standby_delay collectd script into the collectd library plugins directory
  cookbook_file ::File.join(node[:rightscale][:collectd_lib], "plugins", 'check_hot_standby_delay') do
    source "check_hot_standby_delay"
    mode "0755"
    cookbook 'db_postgres'
  end

  # Add a collectd config file for the check_hot_standby_delay script with the exec plugin and restart collectd if necessary
  template ::File.join(node[:rightscale][:collectd_plugin_dir], 'check_hot_standby_delay.conf') do
    source "check_hot_standby_delay_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook 'db_postgres'
  end

  # Setting pg_state and pg_data types for pg slave monitoring into types.db
  ruby_block "add_collectd_gauges" do
    block do
      types_file = ::File.join(node[:rightscale][:collectd_share], 'types.db')
      typesdb = IO.read(types_file)
      unless typesdb.include?('pg_data') && typesdb.include?('pg_state')
        typesdb += "\npg_data                 value:GAUGE:0:9223372036854775807\npg_state                value:GAUGE:0:65535"
        ::File.open(types_file, "w") { |f| f.write(typesdb) }
      end
    end
  end

end

action :generate_dump_file do

  db_name     = new_resource.db_name
  dumpfile    = new_resource.dumpfile

  bash "Write the postgres DB backup file" do
      user 'postgres'
      code <<-EOH
        pg_dump -U postgres -h /var/run/postgresql #{db_name} | gzip -c > #{dumpfile}
      EOH
  end


end

action :restore_from_dump_file do

  db_name     = new_resource.db_name
  dumpfile    = new_resource.dumpfile

  log "  Check if DB already exists"
  ruby_block "checking existing db" do
    block do
      db_check = `echo "select datname from pg_database" | psql -U postgres -h /var/run/postgresql | grep -q  "#{db_name}"`
      if ! db_check.empty?
        raise "ERROR: database '#{db_name}' already exists"
      end
    end
  end

  bash "Import PostgreSQL dump file: #{dumpfile}" do
    user "postgres"
    code <<-EOH
      set -e
      if [ ! -f #{dumpfile} ]
      then
        echo "ERROR: PostgreSQL dumpfile not found! File: '#{dumpfile}'"
        exit 1
      fi
      createdb -U postgres -h /var/run/postgresql #{db_name}
      gunzip < #{dumpfile} | psql -U postgres -h /var/run/postgresql #{db_name}
    EOH
  end

end
