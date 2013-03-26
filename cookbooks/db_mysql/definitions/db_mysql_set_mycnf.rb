#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Sets up my.cnf for configuration file for MySQL database.
#
# @param server_id [String] Database server ID
# @param relay_log [String] Slave relay log information
# @param innodb_log_file_size [Integer] Log file size
# @param compressed_protocol [Boolean] Set if using compression protocols
# @param slave_net_timeout [Integer] Timeout value
# @param ssl_enabled [Boolean] Set to enable SSL authentication
# @param ca_certificate [String] SSL cetificate
# @param master_certificate [String] Master database certificate
# @param master_key [String] Key for the master certificate
#
define :db_mysql_set_mycnf,
  :server_id => nil,
  :relay_log => nil,
  :innodb_log_file_size => nil,
  :compressed_protocol => false,
  :slave_net_timeout => nil,
  :ssl_enabled => nil,
  :ca_certificate => nil,
  :master_certificate => nil,
  :master_key => nil do

  log "  Installing my.cnf with server_id = #{params[:server_id]}," +
    " relay_log = #{params[:relay_log]}"

  template value_for_platform("default" => "/etc/mysql/conf.d/my.cnf") do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => params[:server_id],
      :relay_log => params[:relay_log],
      :innodb_log_file_size => params[:innodb_log_file_size]||
        node[:db_mysql][:tunable][:innodb_log_file_size],
      :compressed_protocol => params[:compressed_protocol] ? "1" : "0",
      :slave_net_timeout => params[:slave_net_timeout]||
        node[:db_mysql][:tunable][:slave_net_timeout],
      :ssl_enabled => params[:ssl_enabled]||
        node[:db_mysql][:ssl_enabled],
      :ca_certificate => params[:ca_certificate]||
        node[:db_mysql][:ssl_credentials][:ca_certificate][:path],
      :master_certificate => params[:master_certificate]||
        node[:db_mysql][:ssl_credentials][:master_certificate][:path],
      :master_key => params[:master_key]||
        node[:db_mysql][:ssl_credentials][:master_key][:path]
    )
    cookbook "db_mysql"
  end

  cookbook_file "/etc/mysql/setup-my-cnf.sh" do
    owner "root"
    group "root"
    mode "0755"
    source "setup_my_cnf.sh"
    cookbook "db_mysql"
  end

  execute "/etc/mysql/setup-my-cnf.sh" do
    user "root"
    group "root"
    umask "0022"
    action :run
  end
end
