#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource db

include RightScale::Database::Helper
include RightScale::Database::MySQL::Helper

# Stop MySQL service
action :stop do
  service node[:db_mysql][:service_name] do
    action :stop
  end
end

# Start MySQL service
action :start do
  begin
    SystemTimer.timeout_after(node[:db_mysql][:init_timeout].to_i) do
      begin
        service node[:db_mysql][:service_name] do
          action :nothing
        end.run_action(:start)
      end until ::File.exists?(node[:db][:socket])
    end
  rescue Timeout::Error
    raise "  Failed to start MySQL: socket file not found."
  end
end

# Restart MySQL service
action :restart do
  service node[:db_mysql][:service_name] do
    action :restart
  end
end

# Check status of MySQL service
action :status do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "status" method.
  @db = init(new_resource)
  status = @db.status
  Chef::Log.info "  Database Status:\n#{status}"
end

# Lock MySQL database
action :lock do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "lock" method.
  @db = init(new_resource)
  @db.lock
end

# Unlock MySQL database
action :unlock do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "unlock" method.
  @db = init(new_resource)
  @db.unlock
end

# Relocate MySQL database data directory
action :move_data_dir do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "move_datadir" method.
  @db = init(new_resource)
  @db.move_datadir(new_resource.name, node[:db_mysql][:datadir])
end

# Wipes the current MySQL database to a pristine state
action :reset do
  # Set read/write in read_write_status.cnf
  db_mysql_set_mysql_read_only "setup mysql read/write" do
    read_only false
  end

  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "reset" method.
  @db = init(new_resource)
  @db.reset(new_resource.name, node[:db_mysql][:datadir])
end

# Sends a remote_recipe that requests a MySQL database to update it's firewall
# rules
action :firewall_update_request do
  # See cookbooks/sys_firewall/providers/default.rb for the "update_request" action.
  sys_firewall "Sending request to open port 3306 (MySQL) allowing this server to connect" do
    machine_tag new_resource.machine_tag
    port 3306
    enable new_resource.enable
    ip_addr new_resource.ip_addr
    action :update_request
  end
end

# Updates MySQL database firewall rules
action :firewall_update do
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "Opening port 3306 (MySQL) for tagged '#{new_resource.machine_tag}' to connect" do
    machine_tag new_resource.machine_tag
    port 3306
    enable new_resource.enable
    action :update
  end
end

# Write backup information needed during restore
action :write_backup_info do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  # See cookbooks/db/libraries/helper.rb for the "RightScale::Database::MySQL::Helper" class.
  db_state_get node
  masterstatus = Hash.new
  masterstatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW MASTER STATUS')
  masterstatus['Master_IP'] = node[:db][:current_master_ip]
  masterstatus['Master_instance_uuid'] = node[:db][:current_master_uuid]
  slavestatus = RightScale::Database::MySQL::Helper.do_query(node, 'SHOW SLAVE STATUS')
  slavestatus ||= Hash.new
  if node[:db][:this_is_master]
    Chef::Log.info "  Backing up Master info"
  else
    Chef::Log.info "  Backing up slave replication status"
    masterstatus['File'] = slavestatus['Relay_Master_Log_File']
    masterstatus['Position'] = slavestatus['Exec_Master_Log_Pos']
  end

  provider = node[:db][:provider]
  version = new_resource.db_version
  Chef::Log.info "  Saving #{provider} version #{version} in master info file"
  masterstatus['DB_Provider'] = provider # save the db provider
  masterstatus['DB_Version'] = version # save the version number

  Chef::Log.info "  Saving master info...:\n#{masterstatus.to_yaml}"
  ::File.open(::File.join(node[:db][:data_dir], RightScale::Database::MySQL::Helper::SNAPSHOT_POSITION_FILENAME), ::File::CREAT|::File::TRUNC|::File::RDWR) do |out|
    YAML.dump(masterstatus, out)
  end
end

# Verify whether MySQL database is in a good state before preforming a restore
action :pre_restore_check do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_restore_sanity_check" method.
  @db = init(new_resource)
  @db.pre_restore_sanity_check
end

# Used to validate backup and cleanup VM after restore
action :post_restore_cleanup do
  # Performs checks for snapshot compatibility with current server.
  # See cookbooks/db_mysql/libraries/helper.rb
  # for the "RightScale::Database::MySQL::Helper" class.
  master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)

  # Checks version matches because not all 11H2 snapshots (prior to 5.5 release)
  # saved provider or version. Assume MySQL 5.1 if nil.
  snap_provider = master_info['DB_Provider'] ||= 'db_mysql'
  current_provider = node[:db][:provider]
  snap_version = master_info['DB_Version'] ||= '5.1'
  Chef::Log.info "  Snapshot from #{snap_provider} version #{snap_version}"


  # mysql_upgrade should only be run if corresponding input is set and snapshot
  # restore from an older version of MySQL is detected.
  run_mysql_upgrade = false

  if snap_provider != current_provider
    raise "FATAL: Wrong snapshot provider detected: #{snap_provider}." +
      " Expected #{current_provider}."
  end

  snap_version = Gem::Version.new(snap_version)
  current_version = Gem::Version.new(new_resource.db_version)
  if snap_version > current_version
    raise "FATAL: Cannot restore snapshot from a newer version of MySQL."
  elsif snap_version == current_version
    Chef::Log.info "  Restore version and provider checks passed."
  elsif snap_version < current_version
    if node[:db_mysql][:enable_mysql_upgrade] == "true"
      run_mysql_upgrade = true
      Chef::Log.info "  Attempting to restore #{snap_provider}" +
        " #{snap_version.version} snapshot to #{current_provider}" +
        " #{current_version.version}." +
        " Will run mysql_upgrade to fix incompatibilities."
    else
      raise "ERROR: Attempting to restore #{snap_provider}" +
        " #{snap_version.version} snapshot to #{current_provider}" +
        " #{current_version.version} without running mysql_upgrade."
    end
  end

  # Creates symlink from package default MySQL datadir to restored datadir.
  default_datadir = "/var/lib/mysql"
  unless ::File.symlink?(default_datadir)
    FileUtils.rm_rf(default_datadir)
    ::File.symlink(node[:db][:data_dir], default_datadir)
  end

  # Compares size of node[:db_mysql][:tunable][:innodb_log_file_size] to
  # actual size of restored /var/lib/mysql/ib_logfile0 (symlink).
  innodb_log_file_size_to_bytes =
    case node[:db_mysql][:tunable][:innodb_log_file_size]
    when /^(\d+)[Kk]$/
      $1.to_i * 1024
    when /^(\d+)[Mm]$/
      $1.to_i * 1024**2
    when /^(\d+)[Gg]$/
      $1.to_i * 1024**3
    when /^(\d+)$/
      $1
    else
      raise "FATAL: unknown log file size"
    end

  if ::File.stat("/var/lib/mysql/ib_logfile0").size == innodb_log_file_size_to_bytes
    Chef::Log.info "  innodb log file sizes the same... OK."
  else # warn if sizes do not match
    Chef::Log.warn "  innodb log file size does not match."
    Chef::Log.warn "  Updating my.cnf to match log file from snapshot."
    Chef::Log.warn "  Discovered size: #{::File.stat("/var/lib/mysql/ib_logfile0").size}"
    Chef::Log.warn "  Expected size: #{innodb_log_file_size_to_bytes}"
  end

  # Always update the my.cnf file on a restore.
  # See cookbooks/db_mysql/definitions/db_mysql_set_mycnf.rb
  # for the "db_mysql_set_mycnf" definition.
  # See cookbooks/db_mysql/libraries/helper.rb
  # for the "RightScale::Database::MySQL::Helper" class.
  db_mysql_set_mycnf "setup_mycnf" do
    server_id RightScale::Database::MySQL::Helper.mycnf_uuid(node)
    relay_log RightScale::Database::MySQL::Helper.mycnf_relay_log(node)
    innodb_log_file_size ::File.stat("/var/lib/mysql/ib_logfile0").size
    compressed_protocol node[:db_mysql][:compressed_protocol] ==
      "enabled" ? true : false
  end

  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "post_restore_cleanup" method.
  @db = init(new_resource)
  @db.post_restore_cleanup

  if run_mysql_upgrade
    # Calls the "start" action.
    db node[:db][:data_dir] do
      action :nothing
      persist false
    end.run_action(:start)

    output = %x[mysql_upgrade]
    exitstatus = $?
    Chef::Log.info output

    if exitstatus.success?
      Chef::Log.info "  mysql_upgrade ran successfully."
    else
      raise "FATAL: mysql_upgrade execution failed!"
    end

    # Calls the "stop" action.
    db node[:db][:data_dir] do
      action :nothing
      persist false
    end.run_action(:stop)
  end

end

# Verify whether the MySQL database is in a good state for taking a snapshot.
action :pre_backup_check do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "pre_backup_check" method.
  @db = init(new_resource)
  @db.pre_backup_check
end

# Used to cleanup VM after backup
action :post_backup_cleanup do
  # See cookbooks/db_mysql/libraries/helper.rb for the "init" method.
  # See "rightscale_tools" gem for the "post_backup_steps" method.
  @db = init(new_resource)
  @db.post_backup_steps
end

# Set MySQL database user privileges
action :set_privileges do
  priv = new_resource.privilege
  priv_username = new_resource.privilege_username
  priv_password = new_resource.privilege_password
  priv_database = new_resource.privilege_database
  # See cookbooks/db_mysql/definitions/db_mysql_set_privileges.rb for the "db_mysql_set_privileges" definition.
  db_mysql_set_privileges "setup db privileges" do
    preset priv
    username priv_username
    password priv_password
    database priv_database
  end
end

# Remove anonymous users from MySQL database
action :remove_anonymous do
  require 'mysql'
  con = Mysql.new('localhost', 'root')
  host = `hostname`.strip
  con.query("DELETE FROM mysql.user WHERE user='' AND host='#{host}'")

  con.close
end

# Install MySQL database client
action :install_client do

  version = new_resource.db_version
  node[:db_mysql][:client_packages_uninstall] = []
  node[:db_mysql][:client_packages_install] = []

  # Socket path.
  node[:db][:socket] = value_for_platform(
    "ubuntu" => {
      "default" => "/var/run/mysqld/mysqld.sock"
    },
    "default" => "/var/lib/mysql/mysql.sock"
  )

  case version
  when "5.1"
    node[:db_mysql][:client_packages_install] = value_for_platform(
      ["centos", "redhat"] => {
        "5.8" => ["MySQL-shared-compat", "MySQL-devel-community", "MySQL-client-community"],
        "default" => ["mysql-devel", "mysql-libs", "mysql"]
      },
      "ubuntu" => {
        "10.04" => ["libmysqlclient-dev", "mysql-client-5.1"],
        "default" => []
      },
      "default" => []
    )

  when "5.5"
    # CentOS/RedHat 6 by default has mysql-libs 5.1 installed as requirement for postfix.
    # Will uninstall mysql-libs, install mysql55-lib.
    node[:db_mysql][:client_packages_uninstall] = value_for_platform(
      ["centos", "redhat"] => {
        "5.8" => [],
        "default" => ["mysql-libs"]
      },
      "default" => []
    )

    node[:db_mysql][:client_packages_install] = value_for_platform(
      ["centos", "redhat"] => {
        "5.8" => ["mysql55-devel", "mysql55-libs", "mysql55"],
        "default" => ["mysql55-devel", "mysql55-libs", "mysql55"]
      },
      "ubuntu" => {
        "10.04" => [],
        "default" => ["libmysqlclient-dev", "mysql-client-5.5"]
      },
      "default" => []
    )

  else
    raise "MySQL version: #{version} not supported yet"
  end

  # Uninstall specified client packages.
  packages = node[:db_mysql][:client_packages_uninstall]
  log "  Packages to uninstall: #{packages.join(",")}" unless packages.empty?
  packages.each do |p|
    use_rpm = version == "5.5" && node[:platform] =~ /redhat|centos/ && node[:platform_version].to_i == 6 && p == "mysql-libs"
    r = package p do
      action :nothing
      options "--nodeps" if use_rpm
      ignore_failure true if use_rpm
      provider Chef::Provider::Package::Rpm if use_rpm
    end
    r.run_action(:remove)
  end

  packages = node[:db_mysql][:client_packages_install]
  log "  Packages to install: #{packages.join(",")}" unless packages == ""
  packages.each do |p|
    r = package p do
      action :nothing
    end
    r.run_action(:install)
  end

  # Installs MySQL client gem in compile phase.
  # It is required by rightscale_tools gem for MySQL operations.
  gem_package "mysql sandbox gem" do
    package_name "mysql"
    version "2.7"
    gem_binary "/opt/rightscale/sandbox/bin/gem"
    options "-- --build-flags --with-mysql-config"
  end

  ruby_block 'clear gem paths for mysql' do
    block do
      Gem.clear_paths
    end
  end
  log "  Gem reload forced with Gem.clear_paths"

end

# Install MySQL database server
action :install_server do

  platform = node[:platform]

  # MySQL server depends on MySQL client.
  # Calls the "install_client" action.
  action_install_client

  # Uninstalls specified server packages.
  packages = node[:db_mysql][:server_packages_uninstall]
  Chef::Log.info "  Packages to uninstall: #{packages.join(",")}" unless packages == ""
  packages.each do |p|
    package p do
      action :remove
    end
  end unless packages == ""

  # Installs required server packages.
  packages = node[:db_mysql][:server_packages_install]
  packages.each do |p|
    package p
  end unless packages == ""

  # Stops MySQL service.
  # See cookbooks/db_mysql/providers/default.rb for the "stop" action.
  db node[:db][:data_dir] do
    action :stop
    persist false
  end

  # Creates MySQL server system tables.
  touchfile = ::File.expand_path "~/.mysql_installed"
  execute "/usr/bin/mysql_install_db ; touch #{touchfile}" do
    creates touchfile
  end

  # Moves MySQL default db to storage location, removes ib_logfiles for re-config of innodb_log_file_size.
  touchfile = ::File.expand_path "~/.mysql_dbmoved"
  ruby_block "clean innodb logfiles" do
    not_if { ::File.exists?(touchfile) }
    block do
      require 'fileutils'
      remove_files = ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ib_logfile*')) + ::Dir.glob(::File.join(node[:db_mysql][:datadir], 'ibdata*'))
      FileUtils.rm_rf(remove_files)
      ::File.open(touchfile, 'a') {}
    end
  end

  # Initializes the binlog dir.
  binlog = ::File.dirname(node[:db_mysql][:log_bin])
  directory binlog do
    owner "mysql"
    group "mysql"
    recursive true
  end

  # Creates the tmp directory.
  directory node[:db_mysql][:tmpdir] do
    owner "mysql"
    group "mysql"
    mode "0770"
    recursive true
  end

  # Creates it so MySQL can use it if configured.
  file "/var/log/mysqlslow.log" do
    owner "mysql"
    group "mysql"
  end

  # Ensures that config directories exist.
  directory "/etc/mysql/conf.d" do
    owner "mysql"
    group "mysql"
    mode "0644"
    recursive true
  end

  # Determine whether to enable SSL for MySQL based on provided inputs.
  # SSL will only be enabled if all inputs are populated.
  node[:db_mysql][:ssl_enabled] =
    !node[:db_mysql][:ssl][:ca_certificate].to_s.empty? &&
    !node[:db_mysql][:ssl][:master_certificate].to_s.empty? &&
    !node[:db_mysql][:ssl][:master_key].to_s.empty? &&
    !node[:db_mysql][:ssl][:slave_certificate].to_s.empty? &&
    !node[:db_mysql][:ssl][:slave_key].to_s.empty?

  node[:db_mysql][:ssl_credentials] = {
    :ca_certificate => {
      :credential => node[:db_mysql][:ssl][:ca_certificate],
      :path => "/etc/mysql/certs/ca_cert.pem"
    },
    :master_certificate => {
      :credential => node[:db_mysql][:ssl][:master_certificate],
      :path => "/etc/mysql/certs/master_cert.pem"
    },
    :master_key => {
      :credential => node[:db_mysql][:ssl][:master_key],
      :path => "/etc/mysql/certs/master_key.pem"
    },
    :slave_certificate => {
      :credential => node[:db_mysql][:ssl][:slave_certificate],
      :path => "/etc/mysql/certs/slave_cert.pem"
    },
    :slave_key => {
      :credential => node[:db_mysql][:ssl][:slave_key],
      :path => "/etc/mysql/certs/slave_key.pem"
    }
  }

  if node[:db_mysql][:ssl_enabled]
    directory "/etc/mysql/certs" do
      owner "mysql"
      group "mysql"
      mode "0700"
    end

    node[:db_mysql][:ssl_credentials].each do |name, data|
      template data[:path] do
        source "credential.pem.erb"
        cookbook "db_mysql"
        owner "mysql"
        group "mysql"
        mode "0400"
        variables(
          :credential => data[:credential]
        )
      end
    end

    m_cmd = "openssl verify -CAfile"
    m_cmd << " #{node[:db_mysql][:ssl_credentials][:ca_certificate][:path]}"
    m_cmd << " #{node[:db_mysql][:ssl_credentials][:master_certificate][:path]}"

    s_cmd = "openssl verify -CAfile"
    s_cmd << " #{node[:db_mysql][:ssl_credentials][:ca_certificate][:path]}"
    s_cmd << " #{node[:db_mysql][:ssl_credentials][:slave_certificate][:path]}"


    ruby_block "verify_certificates" do
      block do
        master = Chef::ShellOut.new(m_cmd)
        master.run_command

        slave = Chef::ShellOut.new(s_cmd)
        slave.run_command

        if master.exitstatus == 0 && slave.exitstatus == 0
          Chef::Log.info master.stdout
          Chef::Log.info slave.stdout
          Chef::Log.info "  Master and Slave certificates verified."
        else
          Chef::Log.info master.stderr
          Chef::Log.info slave.stderr
          raise "FATAL: an error occurred while trying to verify Master and" +
            " Slave certificates against the CA certificate."
        end
      end
    end
  end


  log "  MySQL SSL enabled: #{node[:db_mysql][:ssl_enabled]}"
  log "  MySQL SSL will only be enabled if all inputs contain credentials." do
    not_if { node[:db_mysql][:ssl_enabled] }
  end

  # Sets up my.cnf
  # See cookbooks/db_mysql/definitions/db_mysql_set_mycnf.rb
  # for the "db_mysql_set_mycnf" definition.
  # See cookbooks/db_mysql/libraries/helper.rb
  # for the "RightScale::Database::MySQL::Helper" class.
  db_mysql_set_mycnf "setup_mycnf" do
    server_id RightScale::Database::MySQL::Helper.mycnf_uuid(node)
    relay_log RightScale::Database::MySQL::Helper.mycnf_relay_log(node)
    compressed_protocol node[:db_mysql][:compressed_protocol] ==
      "enabled" ? true : false
  end

  # Setup read_write_status.cnf
  db_mysql_set_mysql_read_only "setup mysql read/write" do
    read_only false
  end

  # Sets up MySQL user limits.
  mysql_file_ulimit = node[:db_mysql][:file_ulimit]
  template "/etc/security/limits.d/mysql.limits.conf" do
    source "mysql.limits.conf.erb"
    variables(
      :ulimit => mysql_file_ulimit
    )
    cookbook "db_mysql"
  end

  # Changes root's limitations for THIS shell. The entry in the limits.d will be
  # used for future logins.
  # The setting needs to be in place before MySQL is started.
  execute "ulimit -n #{mysql_file_ulimit}"

  # Sets up custom mysqld init script via /etc/sysconfig/mysqld.
  # Timeouts enabled.
  # Ubuntu's init script does not support configurable startup timeout
  log_msg = (platform =~ /redhat|centos/) ? "  Setting mysql startup timeout" : "  Skipping mysql startup timeout setting for Ubuntu"
  Chef::Log.info log_msg
  template "/etc/sysconfig/#{node[:db_mysql][:service_name]}" do
    source "sysconfig-mysqld.erb"
    mode "0755"
    cookbook "db_mysql"
    only_if { platform =~ /redhat|centos/ }
  end

  # Specific configs for ubuntu:
  # * sets config file localhost access w/ root and no password
  # * disables the 'check_for_crashed_tables'.
  cookbook_file "/etc/mysql/debian.cnf" do
    only_if { platform == "ubuntu" }
    mode "0600"
    source "debian.cnf"
    cookbook "db_mysql"
  end

  cookbook_file "/etc/mysql/debian-start" do
    only_if { platform == "ubuntu" }
    mode "0755"
    source "debian-start"
    cookbook "db_mysql"
  end

  # Fixes permissions: during the first startup after installation some of the
  # files are created with root:root so MySQL cannot read them.
  dir = node[:db_mysql][:datadir]
  bash "chown mysql #{dir}" do
    flags "-ex"
    code <<-EOH
      chown -R mysql:mysql #{dir}
    EOH
  end

  Chef::Log.info "  Server installed.  Starting MySQL"
  # Starts MySQL.
  # See cookbooks/db_mysql/providers/default.rb for the "start" action.
  db node[:db][:data_dir] do
    action :start
    persist false
  end

  # Verifies MySQL has started before completing this action.
  # Allows MySQL to start before running other commands that would fail
  # unless MySQL has completed starting.
  bash "verifying mysql running" do
    retries 15
    retry_delay 2
    flags "-ex"
    code <<-EOH
      mysql -e "SHOW STATUS LIKE 'uptime'"
    EOH
  end

end

# Installs the driver packages for applications servers based on their
# driver type
action :install_client_driver do
  type = new_resource.driver_type
  log "  Installing mysql support for #{type} driver"

  # Installation of the database client driver for application servers is
  # done here based on the driver type.
  case type
  when "php"
    # This adapter type is used by PHP application servers.
    node[:db][:client][:driver] = "mysql"

    package "#{type} mysql integration" do
      package_name value_for_platform(
        ["centos", "redhat"] => {
          "default" => "php53u-mysql"
        },
        "ubuntu" => {
          "default" => "php5-mysql"
        },
        "default" => "php-mysql"
      )
      action :install
    end
  when "python"
    # This adapter type is used by Django application servers.
    node[:db][:client][:driver] = "django.db.backends.mysql"

    python_pip "MySQL-python" do
      version "1.2.3"
      action :install
    end
  when "java"
    # This adapter type is used by Tomcat application servers.
    node[:db][:client][:driver] = "com.mysql.jdbc.Driver"
    package "#{type} mysql integration" do
      package_name value_for_platform(
        ["centos", "redhat"] => {
          "default" => "mysql-connector-java"
        },
        "ubuntu" => {
          "default" => "libmysql-java"
        }
      )
      action :install
    end
  when "ruby"
    # This adapter type is used by Apache Rails Passenger application servers.
    version = Mixlib::ShellOut.new("ruby --version")
    version.run_command.error!

    case version.stdout
    when /1\.8/
      node[:db][:client][:driver] = "mysql"
    when /1\.9/
      node[:db][:client][:driver] = "mysql2"
    else
      raise "Ruby #{version.stdout} is not supported."
    end

    log "  Setting database adapter to #{node[:db][:client][:driver]}."

    gem_package "mysql system gem" do
      package_name node[:db][:client][:driver]
      gem_binary "/usr/bin/gem"
      options "-- --build-flags --with-mysql-config"
    end
  else
    raise "Unknown driver type specified: #{type}"
  end
end

# Install and configure collectd plugins for the MySQL database server
action :setup_monitoring do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node

  ruby_block "evaluate db type" do
    block do
      if node[:db][:init_status].to_sym == :initialized
        node[:db_mysql][:collectd_master_slave_mode] = (node[:db][:this_is_master] == true ? "Master" : "Slave") + "Stats true"
      else
        node[:db_mysql][:collectd_master_slave_mode] = ""
      end
    end
  end

  service "collectd" do
    action :nothing
  end

  platform = node[:platform]
  # Installs CentOS specific items.
  collectd_version = node[:rightscale][:collectd_packages_version]
  package "collectd-mysql" do
    action :install
    version "#{collectd_version}" unless collectd_version == "latest"
    only_if { platform =~ /redhat|centos/ }
  end

  template ::File.join(node[:rightscale][:collectd_plugin_dir], 'mysql.conf') do
    source "collectd-plugin-mysql.conf.erb"
    mode "0644"
    backup false
    cookbook "db_mysql"
    notifies :restart, resources(:service => "collectd")
  end

  # Sends warning if not centos/redhat or ubuntu.
  log "  WARNING: attempting to install collectd-mysql on unsupported platform #{platform}, continuing.." do
    not_if { platform =~ /centos|redhat|ubuntu/ }
    level :warn
  end

end

# Set database replication privileges for a slave
action :grant_replication_slave do
  require 'mysql'

  Chef::Log.info "GRANT REPLICATION SLAVE to #{node[:db][:replication][:user]}"
  con = Mysql.new('localhost', 'root')
  grant_query = "GRANT REPLICATION SLAVE ON *.* TO"
  grant_query << " '#{node[:db][:replication][:user]}'@'%'"
  grant_query << " IDENTIFIED BY '#{node[:db][:replication][:password]}'"
  grant_query << " REQUIRE SSL" if node[:db_mysql][:ssl_enabled]
  con.query(grant_query)
  con.query("FLUSH PRIVILEGES")
  con.close
end

# Promote slave database to master
action :promote do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node
  force_promote = new_resource.force

  x = node[:db_mysql][:log_bin]
  logbin_dir = x.gsub(/#{::File.basename(x)}$/, "")
  directory logbin_dir do
    action :create
    recursive true
    owner "mysql"
    group "mysql"
  end

  # Set read/write in read_write_status.cnf
  db_mysql_set_mysql_read_only "setup mysql read/write" do
    read_only false
  end

  # Enable binary logging in my.cnf
  node[:db_mysql][:log_bin_enabled] = true

  # Sets up my.cnf
  # See cookbooks/db_mysql/definitions/db_mysql_set_mycnf.rb
  # for the "db_mysql_set_mycnf" definition.
  # See cookbooks/db_mysql/libraries/helper.rb
  # for the "RightScale::Database::MySQL::Helper" class.
  db_mysql_set_mycnf "setup_mycnf" do
    server_id RightScale::Database::MySQL::Helper.mycnf_uuid(node)
    relay_log RightScale::Database::MySQL::Helper.mycnf_relay_log(node)
    innodb_log_file_size ::File.stat("/var/lib/mysql/ib_logfile0").size
    compressed_protocol node[:db_mysql][:compressed_protocol] ==
      "enabled" ? true : false
  end

  # See cookbooks/db_mysql/providers/default.rb for the "start" action.
  db node[:db][:data_dir] do
    action :start
    persist false
    only_if do
      log_bin = RightScale::Database::MySQL::Helper.do_query(
        node,
        "show variables like 'log_bin'",
        'localhost',
        RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
      )
      if log_bin['Value'] == 'OFF'
        Chef::Log.info "  Detected binlogs were disabled, restarting service" +
          " to enable them for Master takeover."
        true
      else
        false
      end
    end
  end

  RightScale::Database::MySQL::Helper.do_query(
    node,
    "SET GLOBAL READ_ONLY=0",
    'localhost',
    RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
  )
  newmasterstatus = RightScale::Database::MySQL::Helper.do_query(
    node,
    'SHOW SLAVE STATUS',
    'localhost',
    RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
  )
  previous_master = node[:db][:current_master_ip]

  if force_promote
    Chef::Log.warn "Forcing the promotion of a slave to master, ignoring" +
      " checks and changes to any current master. This will bring up a master" +
      " with NO replication."
  else
    Chef::Log.warn "Promoting slave and demoting current master. In case" +
      " recipe fails, please review if using the 'Force Promote to Master'" +
      " input will help."
    if previous_master.nil?
      raise "FATAL: could not determine master host from slave status"
    end
    Chef::Log.info "  host: #{previous_master}}"

    # PHASE1: contains non-critical old master operations, if a timeout or
    # error occurs we continue promotion assuming the old master is dead.
    begin
      # OLDMASTER: query with terminate (STOP SLAVE)
      RightScale::Database::MySQL::Helper.do_query(
        node,
        'STOP SLAVE',
        previous_master,
        RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT,
        2
      )

      # OLDMASTER: flush_and_lock_db
      RightScale::Database::MySQL::Helper.do_query(
        node,
        'FLUSH TABLES WITH READ LOCK',
        previous_master,
        5,
        12
      )

      # OLDMASTER:
      masterstatus = RightScale::Database::MySQL::Helper.do_query(
        node,
        'SHOW MASTER STATUS',
        previous_master,
        RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
      )

      # OLDMASTER: unconfigure source of replication
      RightScale::Database::MySQL::Helper.do_query(
        node,
        "CHANGE MASTER TO MASTER_HOST=''",
        previous_master,
        RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
      )

      master_file = masterstatus['File']
      master_position = masterstatus['Position']
      Chef::Log.info "  Retrieved master info...File: #{master_file}" +
        " position: #{master_position}"

      Chef::Log.info "  Waiting for slave to catch up with OLDMASTER (if alive)"
      # NEWMASTER localhost:
      RightScale::Database::MySQL::Helper.do_query(
        node,
        "SELECT MASTER_POS_WAIT('#{master_file}',#{master_position})"
      )
    rescue => e
      Chef::Log.info "  WARNING: caught exception #{e} during non-critical" +
        " operations on the OLD MASTER"
    end
  end

  # PHASE2: reset and promote this slave to master.
  # Critical operations on newmaster, if a failure occurs here we allow it
  # to halt promote operations.
  Chef::Log.info "  Promoting slave.."
  RightScale::Database::MySQL::Helper.do_query(node, 'RESET MASTER')

  newmasterstatus = RightScale::Database::MySQL::Helper.do_query(
    node,
    'SHOW MASTER STATUS'
  )
  newmaster_file = newmasterstatus['File']
  newmaster_position = newmasterstatus['Position']
  Chef::Log.info "  Retrieved new master info...File: #{newmaster_file}" +
    " position: #{newmaster_position}"

  Chef::Log.info "  Stopping slave and misconfiguring master"
  RightScale::Database::MySQL::Helper.do_query(node, "STOP SLAVE")
  RightScale::Database::MySQL::Helper.do_query(node, "RESET SLAVE")
  action_grant_replication_slave
  RightScale::Database::MySQL::Helper.do_query(node, 'SET GLOBAL READ_ONLY=0')

  unless force_promote
    # PHASE3: more non-critical operations, have already made assumption
    # oldmaster is dead.
    begin
      unless previous_master.nil?
        # Unlocks oldmaster.
        RightScale::Database::MySQL::Helper.do_query(
          node,
          'UNLOCK TABLES',
          previous_master
        )
        SystemTimer.timeout_after(
          RightScale::Database::MySQL::Helper::DEFAULT_CRITICAL_TIMEOUT
        ) do
          # Demotes oldmaster.
          # See cookbooks/db/libraries/helper.rb
          # for the "get_local_replication_interface" method.
          Chef::Log.info "  Calling reconfigure replication with host:" +
            " #{previous_master} ip: #{get_local_replication_interface} file:" +
            " #{newmaster_file} position: #{newmaster_position}"
          RightScale::Database::MySQL::Helper.reconfigure_replication(
            node,
            previous_master,
            get_local_replication_interface,
            newmaster_file,
            newmaster_position
          )
        end
      end
    rescue Timeout::Error => e
      Chef::Log.info "  WARNING: rescuing SystemTimer exception #{e}," +
        " continuing with promote"
    rescue => e
      Chef::Log.info "  WARNING: rescuing exception #{e}," +
        " continuing with promote"
    end
  end
end

# Configures and start a slave replicating from master
action :enable_replication do
  # See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
  db_state_get node
  current_restore_process = new_resource.restore_process

  # Check the volume before performing any actions.  If invalid raise error and exit.
  # See cookbooks/db_mysql/libraries/helper.rb for the "RightScale::Database::MySQL::Helper" class.
  ruby_block "validate_master" do
    not_if { current_restore_process == :no_restore }
    block do
      master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)

      # Checks that the snapshot is from the current master or a slave
      # associated with the current master.
      if master_info['Master_instance_uuid']
        if master_info['Master_instance_uuid'] != node[:db][:current_master_uuid]
          raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_uuid']} != current master: #{node[:db][:current_master_uuid]}"
        end
      elsif master_info['Master_instance_id'] # 11H1 backup
        Chef::Log.info "  Detected 11H1 snapshot to migrate"
        if master_info['Master_instance_id'] != node[:db][:current_master_ec2_id]
          raise "FATAL: snapshot was taken from a different master! snap_master was:#{master_info['Master_instance_id']} != current master: #{node[:db][:current_master_ec2_id]}"
        end
      else
        raise "Position and file not saved!" # file not found or does not contain info
      end
    end
  end

  ruby_block "wipe_existing_runtime_config" do
    not_if { current_restore_process == :no_restore }
    block do
      Chef::Log.info "  Wiping existing runtime config files"
      data_dir = ::File.join(node[:db][:data_dir], 'mysql')
      files_to_delete = ["master.info", "relay-log.info", "mysql-bin.*", "*relay-bin.*"]
      files_to_delete.each do |file|
        expand = Dir.glob(::File.join(data_dir, file))
        unless expand.empty?
          expand.each do |exp_file|
            FileUtils.rm_rf(exp_file)
          end
        end
      end
    end
  end

  # Disables binary logging.
  node[:db_mysql][:log_bin_enabled] = false

  unless current_restore_process == :no_restore
    # Sets up my.cnf
    # See cookbooks/db_mysql/definitions/db_mysql_set_mycnf.rb
    # for the "db_mysql_set_mycnf" definition.
    # See cookbooks/db_mysql/libraries/helper.rb
    # for the "RightScale::Database::MySQL::Helper" class.
    db_mysql_set_mycnf "setup_mycnf" do
      server_id RightScale::Database::MySQL::Helper.mycnf_uuid(node)
      relay_log RightScale::Database::MySQL::Helper.mycnf_relay_log(node)
      innodb_log_file_size ::File.stat("/var/lib/mysql/ib_logfile0").size
      compressed_protocol node[:db_mysql][:compressed_protocol] ==
        "enabled" ? true : false
    end
  end

  # Empties out the binary log dir.
  directory ::File.dirname(node[:db_mysql][:log_bin]) do
    not_if { current_restore_process == :no_restore }
    action [:delete, :create]
    recursive true
    owner 'mysql'
    group 'mysql'
  end

  # See cookbooks/db_mysql/providers/default.rb for "start" action.
  db node[:db][:data_dir] do
    action :start
    persist false
  end

  ruby_block "configure_replication" do
    not_if { current_restore_process == :no_restore }
    block do
      master_info = RightScale::Database::MySQL::Helper.load_replication_info(node)
      newmaster_host = master_info['Master_IP']
      newmaster_logfile = master_info['File']
      newmaster_position = master_info['Position']
      RightScale::Database::MySQL::Helper.reconfigure_replication(node, 'localhost', newmaster_host, newmaster_logfile, newmaster_position)
    end
  end

  # Following done after a stop/start and reboot on a slave.
  ruby_block "reconfigure_replication" do
    only_if { current_restore_process == :no_restore }
    block do
      master_info = RightScale::Database::MySQL::Helper.load_master_info_file(node)
      newmaster_host = node[:db][:current_master_ip]
      newmaster_logfile = master_info['File']
      newmaster_position = master_info['Position']
      RightScale::Database::MySQL::Helper.reconfigure_replication(node, 'localhost', newmaster_host, newmaster_logfile, newmaster_position)
    end
  end

  ruby_block "do_query" do
    not_if { current_restore_process == :no_restore }
    block do
      RightScale::Database::MySQL::Helper.do_query(node, "SET GLOBAL READ_ONLY=1")
    end
  end

  # Set read_only in read_write_status.cnf
  db_mysql_set_mysql_read_only "setup mysql read only" do
    read_only true
  end

end

# Generate dump file
action :generate_dump_file do

  db_name = new_resource.db_name
  dumpfile = new_resource.dumpfile

  execute "Write the mysql DB backup file" do
    command "mysqldump --single-transaction -u root #{db_name} | gzip -c > #{dumpfile}"
  end

end

# Restore MySQL database from dump file
action :restore_from_dump_file do

  db_name = new_resource.db_name
  dumpfilepath_without_extension = new_resource.dumpfile
  db_check = `mysql -e "SHOW DATABASES LIKE '#{db_name}'"`

  Chef::Log.info "  Check if DB already exists"
  ruby_block "checking existing db" do
    block do
      if !db_check.empty?
        Chef::Log.warn "  WARNING: database '#{db_name}' already exists." +
          " No changes will be made to existing database."
      end
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

  ruby_block "Import MySQL dump file" do
    block do
      if ::File.exists?(node[:db][:dump][:filepath])
        # Create the database
        Chef::Log.info "  Creating DB #{db_name}..."
        create_db = Mixlib::ShellOut.new("mysqladmin -u root create #{db_name}")
        create_db.run_command
        create_db.error!

        # Import comtents from dump file to the database
        Chef::Log.info "  Importing contents from dumpfile:" +
          " #{node[:db][:dump][:filepath]}"
        import_dump = Mixlib::ShellOut.new(
          "#{node[:db][:dump][:uncompress_command]} #{node[:db][:dump][:filepath]} |" +
          " mysql -u root -b #{db_name}"
        )
        import_dump.run_command
        import_dump.error!
      else
        raise "MySQL dump file not found: #{node[:db][:dump][:filepath]}"
      end
    end
    only_if { db_check.empty? }
  end
end
