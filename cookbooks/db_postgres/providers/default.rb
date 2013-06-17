#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

include RightScale::Database::Helper
include RightScale::Database::PostgreSQL::Helper

action :stop do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "stop" method.
  @db = init(new_resource)
  @db.stop
end

action :start do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "start" method.
  @db = init(new_resource)
  @db.start
end

action :status do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "status" method.
  @db = init(new_resource)
  status = @db.status
  log "Database Status:\n#{status}"
end

action :lock do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "lock" method.
  @db = init(new_resource)
  @db.lock
end

action :unlock do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "unlock" method.
  @db = init(new_resource)
  @db.unlock
end

action :move_data_dir do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "move_datadir" method.
  @db = init(new_resource)
  @db.move_datadir(new_resource.name, node[:db_postgres][:datadir])
end

action :reset do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "reset" method.
  @db = init(new_resource)
  @db.reset(new_resource.name, node[:db_postgres][:datadir])
end

action :firewall_update_request do
  # See cookbooks/sys_firewall/providers/default.rb for the "update_request" action.
  sys_firewall node[:db_postgres][:port] do
    machine_tag new_resource.machine_tag
    enable new_resource.enable
    ip_addr new_resource.ip_addr
    action :update_request
  end
end

action :firewall_update do
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall node[:db_postgres][:port] do
    machine_tag new_resource.machine_tag
    enable new_resource.enable
    action :update
  end
end

action :write_backup_info do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
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
  # See cookbooks/db_postgres/libraries/helper.rb for the "RightScale::Database::PostgreSQL::Helper" class.
  ::File.open(::File.join(node[:db][:data_dir], RightScale::Database::PostgreSQL::Helper::SNAPSHOT_POSITION_FILENAME), ::File::CREAT|::File::TRUNC|::File::RDWR) do |out|
    YAML.dump(masterstatus, out)
  end
end

action :pre_restore_check do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_restore_sanity_check" method.
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

action :post_restore_cleanup do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "restore_snapshot" method.
  @db = init(new_resource)
  @db.restore_snapshot
end

action :pre_backup_check do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_backup_check" method.
  @db = init(new_resource)
  @db.pre_backup_check
end

action :post_backup_cleanup do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "post_backup_steps" method.
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
    # See cookbooks/db_postgres/definitions/db_postgres_set_privileges.rb for the "db_postgres_set_privileges" definition.
    db_postgres_set_privileges "setup db privileges" do
      preset priv
      username priv_username
      password priv_password
      database priv_database
    end
  end
end

action :install_client do
  version = new_resource.db_version
  case version
  when "9.1"
    node[:db_postgres][:client_packages_install] = value_for_platform(
      ["centos", "redhat"] => {
        "default" => [
          "libxslt",
          "postgresql91-libs",
          "postgresql91",
          "postgresql91-devel"
        ]
      },
      "default" => []
    )

    node[:db_postgres][:bindir] = value_for_platform(
      ["centos", "redhat"] => {
        "default" => "/usr/pgsql-9.1/bin"
      }
    )
  else
    raise "PostgreSQL version '#{version}'is not supported yet."
  end

  # Installs PostgreSQL package(s).
  packages = node[:db_postgres][:client_packages_install]
  raise "Platform not supported for PostgreSQL #{version}" if packages.empty?

  log "  Packages to install: #{packages.join(", ")}"
  packages.each do |p|
    package p do
      action :install
    end
  end

  # Link PostgreSQL pg_config to default system bin path - this is required by
  # the Application servers.
  link "/usr/bin/pg_config" do
    to "#{node[:db_postgres][:bindir]}/pg_config"
    not_if { ::File.exists?("/usr/bin/pg_config") }
  end

  # Installs PostgreSQL client gem.
  gem_package "pg" do
    gem_binary "/opt/rightscale/sandbox/bin/gem"
    options "-- --with-pg-config=#{node[:db_postgres][:bindir]}/pg_config"
  end
end

action :install_server do
  package "uuid"

  packages = node[:db_postgres][:server_packages_install]
  log "  Packages to install: #{packages.join(",")}"
  packages.each do |p|
    package p do
      action :install
    end
  end

  service node[:db_postgres][:service_name] do
    supports :status => true, :restart => true, :reload => true
    action :stop
  end

  # Initializes PostgreSQL server and creates system tables.
  execute "/etc/init.d/#{node[:db_postgres][:service_name]} initdb" do
    not_if { ::File.exists?("#{node[:db_postgres][:confdir]}/postgresql.conf") }
  end

  # Configure system for PostgreSQL
  #
  # Stop PostgreSQL
  service node[:db_postgres][:service_name] do
    action :stop
  end

  # Shared servers get 50% of the resources allocated to a dedicated server.
  usage = node[:db_postgres][:server_usage] == "shared" ? 0.5 : 1

  # Converts memory from kB to MB.
  mem = node[:memory][:total].to_i / 1024
  log "  Auto-tuning PostgreSQL parameters. Total memory: #{mem}MB"

  # Sets tuning parameters.
  node[:db_postgres][:tunable][:max_connections] ||= (400 * usage).to_i
  node[:db_postgres][:tunable][:shared_buffers] ||=
    value_with_units((mem * 0.25).to_i, "MB", usage)

  # Set the postgres and root users max open files to a really large number.
  # 1/3 of the overall system file max should be large enough.
  # The percentage can be adjusted if necessary.
  ulimit = Mixlib::ShellOut.new("sysctl -n fs.file-max")
  ulimit.run_command.error!
  node[:db_postgres][:tunable][:ulimit] ||= ulimit.stdout.to_i / 33

  # See cookbooks/db_postgres/definitions/db_postgres_set_psqlconf.rb
  # for the "db_postgres_set_psqlconf" definition.
  db_postgres_set_psqlconf "setup_postgresql_conf"

  # Setup pg_hba.conf
  # pg_hba_source = "pg_hba.conf.erb"
  cookbook_file "#{node[:db_postgres][:confdir]}/pg_hba.conf" do
    source "pg_hba.conf"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook 'db_postgres'
    not_if {
      ::Dir.glob("#{node[:db_postgres][:confdir]}/pg_hba.conf.chef*").any?
    }
  end

  # Setup PostgreSQL user limits
  #
  template "/etc/security/limits.d/postgres.limits.conf" do
    source "postgres.limits.conf.erb"
    variables({
      :ulimit => node[:db_postgres][:tunable][:ulimit]
    })
    cookbook 'db_postgres'
  end

  # Change root's limitations for THIS shell.  The entry in the limits.d will be
  # used for future logins.
  # The setting needs to be in place before postgresql-9 is started.
  execute "ulimit -n #{node[:db_postgres][:tunable][:ulimit]}"

  # Start PostgreSQL
  service node[:db_postgres][:service_name] do
    action :start
  end
end

action :install_client_driver do
  type = new_resource.driver_type
  log "  Installing postgres support for #{type} driver"

  # Installation of the database client driver for application servers is
  # done here based on the client driver type
  case type
  when "php"
    # This adapter type is used by php application servers
    node[:db][:client][:driver] = "postgres"
    package "#{type} postgres integration" do
      package_name value_for_platform(
        ["centos", "redhat"] => {
          "default" => "php53u-pgsql"
        },
        "ubuntu" => {
          "default" => "php5-pgsql"
        },
        "default" => "php5-pgsql"
      )
      action :install
    end
  when "python"
    # This adapter type is used by Django application servers
    node[:db][:client][:driver] = "django.db.backends.postgresql_psycopg2"
    python_pip "psycopg2" do
      version "2.4.5"
      action :install
    end
  when "java"
    # This adapter type is used by tomcat application servers
    node[:db][:client][:driver] = "org.postgresql.Driver"
    cookbook_file "/usr/share/java/#{node[:db][:client][:jar_file]}" do
      source "#{node[:db][:client][:jar_file]}"
      owner "root"
      group "root"
      mode "0644"
      cookbook "db_postgres"
    end
  when "ruby"
    # This adapter type is used by Apache Rails Passenger application servers
    node[:db][:client][:driver] = "postgresql"
    postgres_bin_dir = "/usr/pgsql-#{node[:db][:version]}/bin"
    gem_package 'pg' do
      gem_binary "/usr/bin/gem"
      options "-- --with-pg-config=#{postgres_bin_dir}/pg_config"
    end
  else
    raise "Unknown driver type specified: #{type}"
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
  slavestatus = res.getvalue(0, 0)
  if (slavestatus == 'off')
    log "  Detected Master server."
    result = conn.exec("SELECT COUNT(*) FROM pg_user WHERE usename='#{username_esc}'")
    userstat = result.getvalue(0, 0)
    if (userstat == '1')
      log "  User #{username} already exists, updating user using current inputs"
      conn.exec("ALTER USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")
    else
      log "  Creating replication user #{username}"
      conn.exec("CREATE USER #{username} SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN ENCRYPTED PASSWORD '#{password}'")

      # Configures the replication parameters.
      RightScale::Database::PostgreSQL::Helper.configure_pg_hba(node)

      # Reload postgresql to read new updated pg_hba.conf
      # See cookbooks/db_postgres/libraries/helper.rb
      # for the "RightScale::Database::PostgreSQL::Helper" class.
      RightScale::Database::PostgreSQL::Helper.do_query('select pg_reload_conf()')
    end
  else
    log "  Do nothing, Detected read_only db or slave mode"
  end
  conn.finish
end

action :enable_replication do
  # See cookbooks/db/libraries/helper.rb for "db_state_get" method.
  db_state_get node
  current_restore_process = new_resource.restore_process

  # Check the volume before performing any actions.  If invalid raise error and exit.
  ruby_block "validate_master" do
    not_if { current_restore_process == :no_restore }
    # See cookbooks/db_postgres/libraries/helper.rb for the "RightScale::Database::PostgreSQL::Helper" class.
    block do
      master_info = RightScale::Database::PostgreSQL::Helper.load_replication_info(node)

      # Check that the snapshot is from the current master or a slave associated with the current master
      raise "Position and file not saved or it does not contain info!" unless master_info['Master_instance_uuid']
      raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_uuid']} != current master: #{node[:db][:current_master_uuid]}" unless master_info['Master_instance_uuid'] == node[:db][:current_master_uuid]
    end
  end

  # Stopping Postgresql service
  service node[:db_postgres][:service_name] do
    not_if { current_restore_process == :no_restore }
    action :stop
  end

  ruby_block "Sync to Master data" do
    not_if { current_restore_process == :no_restore }
    block do
      RightScale::Database::PostgreSQL::Helper.rsync_db(
        node[:db][:current_master_ip],
        node[:db][:replication][:user]
      )
    end
  end

  template "#{node[:db_postgres][:confdir]}/recovery.conf" do
    source "recovery.conf.erb"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook "db_postgres"
    variables(
      :host => RightScale::Database::PostgreSQL::Helper.load_replication_info(
        node
      )["Master_IP"],
      :user => node[:db][:replication][:user],
      :password => node[:db][:replication][:password],
      :application_name => node[:rightscale][:instance_uuid],
      :trigger_file => "#{node[:db_postgres][:confdir]}/recovery.trigger"
    )
    not_if { current_restore_process == :no_restore }
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
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  previous_master = node[:db][:current_master_ip]
  raise "FATAL: could not determine master host from slave status" if previous_master.nil?
  log "  host: #{previous_master}}"

  begin
    # Promote the slave into the new master
    log "  Promoting slave.."
    # See cookbooks/db_postgres/libraries/helper.rb for the "RightScale::Database::PostgreSQL::Helper" class.
    RightScale::Database::PostgreSQL::Helper.write_trigger(node)
    sleep 10

    # Let the new slave loose and thus let him become the new master
    log "  New master is ReadWrite."

  rescue => e
    log "  WARNING: caught exception #{e} during critical operations on the MASTER"
  end
end

action :setup_monitoring do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  service "collectd" do
    action :nothing
  end

  collectd_version = node[:rightscale][:collectd_packages_version]
  package "collectd-postgresql" do
    action :install
    version "#{collectd_version}" unless collectd_version == "latest"
  end

  cookbook_file "#{node[:rightscale][:collectd_share]}/postgresql_default.conf" do
    source "postgresql_default.conf"
    backup false
    cookbook "db_postgres"
    notifies :restart, resources(:service => "collectd")
  end

  # Installs the postgres_ps collectd script into the collectd library plugins
  # directory.
  cookbook_file "#{node[:rightscale][:collectd_lib]}/plugins/postgres_ps" do
    source "postgres_ps"
    mode "0755"
    cookbook "db_postgres"
  end

  # Adds a collectd config file for the postgres_ps script with the exec
  # plugin and restarts collectd if necessary.
  template "#{node[:rightscale][:collectd_plugin_dir]}/postgres_ps.conf" do
    source "postgres_ps.conf.erb"
    cookbook "db_postgres"
    notifies :restart, resources(:service => "collectd")
  end
end

action :setup_slave_monitoring do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  service "collectd" do
    action :nothing
  end

  # Sets up monitoring for slave replication: since it is hard to define the
  # lag - we monitor the master/slave sync health status.

  # Installs the 'pg_cluster_status' collectd script into the collectd library
  # plugins directory.
  template "#{node[:rightscale][:collectd_lib]}/plugins/pg_cluster_status" do
    source "pg_cluster_status.erb"
    mode "0755"
    cookbook "db_postgres"
    variables(
      :bindir => node[:db_postgres][:bindir],
      :datadir => node[:db_postgres][:datadir]
    )
  end

  # Adds a collectd configuration file for the 'pg_cluster_status' script with
  # the exec plugin and restarts collectd if necessary.
  template ::File.join(
    node[:rightscale][:collectd_plugin_dir],
    "pg_cluster_status.conf"
  ) do
    source "pg_cluster_status_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook "db_postgres"
  end

  # Installs the 'check_hot_standby_delay' collectd script into the collectd
  # library plugins directory.
  template ::File.join(
    node[:rightscale][:collectd_lib],
    "plugins",
    "check_hot_standby_delay"
  ) do
    source "check_hot_standby_delay.erb"
    mode "0755"
    cookbook "db_postgres"
    variables(
      :bindir => node[:db_postgres][:bindir],
      :datadir => node[:db_postgres][:datadir]
    )
  end

  # Adds a collectd configuration file for the 'check_hot_standby_delay' script
  # with the exec plugin and restarts collectd if necessary.
  template ::File.join(
    node[:rightscale][:collectd_plugin_dir],
    "check_hot_standby_delay.conf"
  ) do
    source "check_hot_standby_delay_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook "db_postgres"
  end

  # Adds custom gauges to collectd 'types.db'.
  cookbook_file "#{node[:rightscale][:collectd_plugin_dir]}/psql.types.db" do
    source "psql.types.db"
    cookbook "db_postgres"
    backup false
  end

  # Adds configuration to use the custom gauges.
  template "#{node[:rightscale][:collectd_plugin_dir]}/psql.types.db.conf" do
    source "psql.types.db.conf.erb"
    cookbook "db_postgres"
    variables(
      :collectd_plugin_dir => node[:rightscale][:collectd_plugin_dir]
    )
    backup false
    notifies :restart, resources(:service => "collectd")
  end
end

action :generate_dump_file do
  db_name = new_resource.db_name
  dumpfile = new_resource.dumpfile

  bash "Write the postgres DB backup file" do
    user 'postgres'
    code <<-EOH
      pg_dump -U postgres #{db_name} | gzip -c > #{dumpfile}
    EOH
  end
end

action :restore_from_dump_file do
  db_name = new_resource.db_name
  dumpfilepath_without_extension = new_resource.dumpfile

  log "  Check if DB already exists"
  ruby_block "checking existing db" do
    block do
      query = "echo \"select datname from pg_database\" |" +
        " psql -U | grep -q  \"#{db_name}\""
      db_check = `#{query}`
      raise "ERROR: database '#{db_name}' already exists" unless db_check.empty?
    end
  end

  # Detect the compression type of the downloaded file and set the
  # extension properly.
  node[:db][:dump][:filepath] = ""
  node[:db][:dump][:uncompress_command] = ""
  ruby_block "Detect compression type" do
    block do
      require "fileutils"

      file_type = Mixlib::ShellOut.new("file #{dumpfilepath_without_extension}")
      file_type.run_command
      file_type.error!
      command_output = file_type.stdout

      extension = ""
      if command_output =~ /Zip archive data/
        extension = "zip"
        node[:db][:dump][:uncompress_command] = "unzip -p"
      elsif command_output =~ /gzip compressed data/
        extension = "gz"
        node[:db][:dump][:uncompress_command] = "gunzip <"
      elsif command_output =~ /bzip2 compressed data/
        extension = "bz2"
        node[:db][:dump][:uncompress_command] = "bunzip2 <"
      end
      node[:db][:dump][:filepath] = dumpfilepath_without_extension +
        "." +
        extension
      FileUtils.mv(dumpfilepath_without_extension, node[:db][:dump][:filepath])
    end
  end

  ruby_block "Import PostgreSQL dump file" do
    block do
      if ::File.exists?(node[:db][:dump][:filepath])
        # Create the database
        Chef::Log.info "  Creating DB #{db_name}..."
        create_db = Mixlib::ShellOut.new("createdb -U postgres #{db_name}")
        create_db.run_command
        create_db.error!

        # Import comtents from dump file to the database
        Chef::Log.info "  Importing contents from dumpfile:" +
          " #{node[:db][:dump][:filepath]}"
        import_dump = Mixlib::ShellOut.new(
          "#{node[:db][:dump][:uncompress_command]} #{node[:db][:dump][:filepath]} |" +
            " psql -U postgres #{db_name}"
        )
        import_dump.run_command
        import_dump.error!
      else
        raise "PostgreSQL dump file not found: #{node[:db][:dump][:filepath]}"
      end
    end
  end
end
