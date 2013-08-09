#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource db

include RightScale::Database::Helper
include RightScale::Database::PostgreSQL::Helper

# Stops Postgres service
action :stop do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "stop" method.
  @db = init(new_resource)
  @db.stop
end

# Starts Postgres service
action :start do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "start" method.
  @db = init(new_resource)
  @db.start
end

# Checks status of Postgres service
action :status do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "status" method.
  @db = init(new_resource)
  status = @db.status
  log "Database Status:\n#{status}"
end

# Locks Postgres database
action :lock do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "lock" method.
  @db = init(new_resource)
  @db.lock
end

# Unlocks Postgres database
action :unlock do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "unlock" method.
  @db = init(new_resource)
  @db.unlock
end

# Relocates the Postgres database data directory
action :move_data_dir do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "move_datadir" method.
  @db = init(new_resource)
  @db.move_datadir(new_resource.name, node[:db_postgres][:datadir])
end

# Resets Postgres database to a pristine state
action :reset do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "reset" method.
  @db = init(new_resource)
  @db.reset(new_resource.name, node[:db_postgres][:datadir])
end

# Sends a firewall update request to the Postgres database server
action :firewall_update_request do
  # See cookbooks/sys_firewall/providers/default.rb
  # for the "update_request" action.
  sys_firewall "Requesting #{node[:db_postgres][:port]} port for PostgreSQL" do
    machine_tag new_resource.machine_tag
    port node[:db_postgres][:port].to_i
    enable new_resource.enable
    ip_addr new_resource.ip_addr
    action :update_request
  end
end

# Updates database firewall rules
action :firewall_update do
  # See cookbooks/sys_firewall/providers/default.rb
  # for the "update" action.
  sys_firewall "Opening #{node[:db_postgres][:port]} port for PostgreSQL" do
    machine_tag new_resource.machine_tag
    port node[:db_postgres][:port].to_i
    enable new_resource.enable
    action :update
  end
end

# Writes backup information needed during restore
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
  # See cookbooks/db/libraries/helper.rb
  # for the "RightScale::Database::Helper" class.
  ::File.open(
    ::File.join(node[:db][:data_dir],
    RightScale::Database::Helper::SNAPSHOT_POSITION_FILENAME),
    ::File::CREAT|::File::TRUNC|::File::RDWR
  ) do |out|
    YAML.dump(masterstatus, out)
  end
end

# Verifies Postgres database is in a pristine state before performing a restore to
# prevent overwriting of an existing database
action :pre_restore_check do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_restore_sanity_check" method.
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

# Validates backup and cleans up instance after restore
action :post_restore_cleanup do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "restore_snapshot" method.
  @db = init(new_resource)
  @db.restore_snapshot
end

# Verifies the database is in a good state for taking a backup.
action :pre_backup_check do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_backup_check" method.
  @db = init(new_resource)
  @db.pre_backup_check
end

# Cleans up instance after backup
action :post_backup_cleanup do
  # See cookbooks/db_postgres/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "post_backup_steps" method.
  @db = init(new_resource)
  @db.post_backup_steps
end

# Sets database privileges
action :set_privileges do

  if ::File.exist?("#{node[:db_postgres][:datadir]}/recovery.conf")
    log "  No privileges to be set on slave/standby server"
  else
    log "  Setting privileges on server"
    priv = new_resource.privilege
    priv_username = new_resource.privilege_username
    priv_password = new_resource.privilege_password
    priv_database = new_resource.privilege_database

    # See cookbooks/db_postgres/definitions/db_postgres_set_privileges.rb
    # for the "db_postgres_set_privileges" definition.
    db_postgres_set_privileges "setup db privileges" do
      preset priv
      username priv_username
      password priv_password
      database priv_database
    end
  end

end

# Installs database client
action :install_client do
  version = new_resource.db_version
  if version == "9.1"
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
    raise "PostgreSQL version '#{version}' is not supported yet."
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

  # It is required by rightscale_tools gem for PostgreSQL operations.
  gem_package "pg" do
    gem_binary "/opt/rightscale/sandbox/bin/gem"
    options "-- --with-pg-config=#{node[:db_postgres][:bindir]}/pg_config"
  end
end

# Installs database server
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

  # Creates a new PostgreSQL database cluster.
  execute "service #{node[:db_postgres][:service_name]} initdb" do
    not_if { ::File.exists?("#{node[:db_postgres][:confdir]}/postgresql.conf") }
  end

  # Configures system for PostgreSQL.
  #
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
      ::Dir.glob("#{node[:db_postgres][:confdir]}/pg_hba.conf.*").any?
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

# Installs the Postgres client driver packages
action :install_client_driver do
  type = new_resource.driver_type
  version = new_resource.db_version
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
    # This adapter type is required by application servers,
    # such as JBoss and Tomcat.
    node[:db][:client][:driver] = "org.postgresql.Driver"
    if version == "9.1"
      node[:db][:client][:jar_file] = value_for_platform(
        ["centos", "redhat"] => {
          "default" => "postgresql-9.1-901.jdbc4.jar"
        }
      )
    else
      raise "PostgreSQL version '#{version}'is not supported yet."
    end

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

# Sets database replication privileges for a slave
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
      file = Chef::Util::FileEdit.new(
        "#{node[:db_postgres][:confdir]}/pg_hba.conf"
      )

      line = "host replication #{node[:db][:replication][:user]}"
      line << " 0.0.0.0/0 trust"

      file.insert_line_if_no_match(line, line)
      file.write_file

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

# Configures replication between a slave server and master
action :enable_replication do
  # See cookbooks/db/libraries/helper.rb for "db_state_get" method.
  db_state_get node
  current_restore_process = new_resource.restore_process

  # Check the volume before performing any actions.  If invalid raise error and exit.
  ruby_block "validate_master" do
    not_if { current_restore_process == :no_restore }
    # See cookbooks/db/libraries/helper.rb
    # for the "RightScale::Database::Helper" class.
    block do
      master_info = RightScale::Database::Helper.load_replication_info(node)

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

  template "#{node[:db_postgres][:confdir]}/recovery.conf" do
    source "recovery.conf.erb"
    owner "postgres"
    group "postgres"
    mode "0644"
    cookbook "db_postgres"
    variables(
      :host => RightScale::Database::Helper.load_replication_info(
        node
      )["Master_IP"],
      :user => node[:db][:replication][:user],
      :password => node[:db][:replication][:password],
      :application_name => node[:rightscale][:instance_uuid],
      :trigger_file => "#{node[:db_postgres][:confdir]}/recovery.trigger"
    )
    not_if { current_restore_process == :no_restore }
    action :nothing
  end.run_action(:create)

  # Remove old/stale xlog files.
  bash "wipe_existing_xlog_files" do
    not_if { current_restore_process == :no_restore }
    flags "-ex"
    code <<-EOH
       rm -rf #{node[:db_postgres][:datadir]}/pg_xlog/*
    EOH
  end

  # After removing old/stale xlog files, copy archived xlog files.
  bash "copy_archived_xlog_files" do
    not_if { current_restore_process == :no_restore }
    flags "-ex"
    code <<-EOH
       cp -a #{node[:db_postgres][:datadir]}/archivedir/* #{node[:db_postgres][:datadir]}/pg_xlog/
    EOH
  end

  # Ensure that database started
  # service provider uses the status command to decide if it
  # has to run the start command again.
  ruby_block "Start Postgresql service" do
    block do
      action_start
    end
    retries 5
    retry_delay 2
  end

  # Setup slave monitoring
  action_setup_slave_monitoring
end

# Promotes a slave server to the master server
action :promote do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  previous_master = node[:db][:current_master_ip]
  raise "FATAL: could not determine master host from slave status" if previous_master.nil?
  log "  Current master: #{previous_master}"

  begin
    # Promote the slave into the new master
    log "  Promoting slave.."

    # The slave server has the 'wal receiver' process running, once we promote
    # it to master, streaming replication should be stopped.
    ruby_block "verify no receiver process" do
      block do
        60.downto(0) do |try|
          cmd = Mixlib::ShellOut.new("ps ax | grep '[w]al receiver process'")
          cmd.run_command
          break if cmd.stdout.empty?
          Chef::Log.info cmd.stdout.chomp
          raise "FATAL: 'wal receiver' process is still running!" if try.zero?
          Chef::Log.info "  Waiting for 'wal receiver' process to terminate."
          sleep 10
        end
      end
      action :nothing
    end

    # Creates a trigger file, the presence of which should cause streaming
    # replication to end whether or not the next WAL file is available.
    # Immediately calls "check receiver process" to verify that server is no
    # longer a slave.
    file "#{node[:db_postgres][:confdir]}/recovery.trigger" do
      notifies :create, "ruby_block[verify no receiver process]", :immediately
    end

    # Let the new slave loose and thus let him become the new master
    log "  New master is ReadWrite."

  rescue => e
    raise "Caught exception during critical operations on the MASTER: '#{e}'"
  end
end

# Installs and configures collectd plugins for the server
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
    variables(
      :collectd_lib => node[:rightscale][:collectd_lib],
      :instance_uuid => node[:rightscale][:instance_uuid]
    )
  end
end

# Sets up monitoring for slave database
action :setup_slave_monitoring do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  service "collectd" do
    action :nothing
  end

  collectd_lib_dir = node[:rightscale][:collectd_lib]
  collectd_plugin_dir = node[:rightscale][:collectd_plugin_dir]
  pg_bin_dir = node[:db_postgres][:bindir]
  pg_data_dir = node[:db_postgres][:datadir]

  # Sets up monitoring for slave replication: since it is hard to define the
  # lag - we monitor the master/slave sync health status.

  # Installs the 'pg_cluster_status' collectd script into the collectd library
  # plugins directory.
  template "#{collectd_lib_dir}/plugins/pg_cluster_status" do
    source "pg_cluster_status.erb"
    mode "0755"
    cookbook "db_postgres"
    variables(
      :bindir => pg_bin_dir,
      :datadir => pg_data_dir
    )
  end

  # Adds a collectd configuration file for the 'pg_cluster_status' script with
  # the exec plugin and restarts collectd if necessary.
  template "#{collectd_plugin_dir}/pg_cluster_status.conf" do
    source "pg_cluster_status_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook 'db_postgres'
    variables(
      :collectd_lib => node[:rightscale][:collectd_lib],
      :current_master_ip => node[:db][:current_master_ip],
      :private_ip => node[:cloud][:private_ips][0],
      :instance_uuid => node[:rightscale][:instance_uuid]
    )
  end

  # Installs the 'check_hot_standby_delay' collectd script into the collectd
  # library plugins directory.
  template "#{collectd_lib_dir}/plugins/check_hot_standby_delay" do
    source "check_hot_standby_delay.erb"
    mode "0755"
    cookbook "db_postgres"
    variables(
      :bindir => pg_bin_dir,
      :datadir => pg_data_dir
    )
  end

  # Adds a collectd configuration file for the 'check_hot_standby_delay' script
  # with the exec plugin and restarts collectd if necessary.
  template "#{collectd_plugin_dir}/check_hot_standby_delay.conf" do
    source "check_hot_standby_delay_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook 'db_postgres'
    variables(
      :collectd_lib => node[:rightscale][:collectd_lib],
      :current_master_ip => node[:db][:current_master_ip],
      :private_ip => node[:cloud][:private_ips][0],
      :instance_uuid => node[:rightscale][:instance_uuid]
    )
  end

  # Adds custom gauges to collectd 'types.db'.
  cookbook_file "#{collectd_plugin_dir}/psql.types.db" do
    source "psql.types.db"
    cookbook "db_postgres"
    backup false
  end

  # Adds configuration to use the custom gauges.
  template "#{collectd_plugin_dir}/psql.types.db.conf" do
    source "psql.types.db.conf.erb"
    cookbook "db_postgres"
    variables(
      :collectd_plugin_dir => collectd_plugin_dir
    )
    backup false
    notifies :restart, resources(:service => "collectd")
  end
end

# Generates database dump file
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

# Restores database from a dump file
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
