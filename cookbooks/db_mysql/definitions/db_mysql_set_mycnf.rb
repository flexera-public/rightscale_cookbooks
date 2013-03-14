#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define(:db_mysql_set_mycnf,
  :hostname => nil,

  # Basic Settings
  :socket => nil,
  :datadir => nil,
  :tmpdir => nil,
  :bind_address => nil,

  # Fine Tuning
  :key_buffer => nil,
  :thread_cache_size => nil,
  :max_connections => nil,
  :wait_timeout => nil,
  :net_read_timeout => nil,
  :net_write_timeout => nil,
  :back_log => nil,
  :table_cache => nil,
  :max_heap_table_size => nil,
  :sort_buffer_size => nil,
  :read_buffer_size => nil,
  :read_rnd_buffer_size => nil,
  :myisam_sort_buffer_size => nil,
  :net_buffer_length => nil,

  # Query Cache Configuration
  :query_cache_size => nil,

  # Logging and Replication
  :log => nil,
  :log_error => nil,
  :log_slow_queries => nil,
  :long_query_time => nil,
  :read_only => nil,
  :server_id => nil,
  :log_bin_enabled => nil,
  :log_bin => nil,
  :expire_logs_days => nil,
  :binlog_format => nil,

  # InnoDB
  :innodb_buffer_pool_size => nil,
  :innodb_additional_mem_pool_size => nil,
  :innodb_log_file_size => nil,
  :innodb_log_buffer_size =>nil,
  :data_dir => nil,
  :relay_log => nil,

  :compressed_protocol => false,

  # SSL
  :ssl_enabled => nil,
  :ca_certificate => nil,
  :master_certificate => nil,
  :master_key => nil,
  :version => nil,
  :isamchk_key_buffer => nil,
  :isamchk_sort_buffer_size => nil
) do

  log "  Installing my.cnf with server_id = #{params[:server_id]}," +
    " relay_log = #{params[:relay_log]}"

  template value_for_platform("default" => "/etc/mysql/conf.d/my.cnf") do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :hostname => node[:hostname],
      # Basic Settings
      :socket => node[:db][:socket],
      :datadir => node[:db_mysql][:datadir],
      :tmpdir => node[:db_mysql][:tmpdir],
      :bind_address => node[:db_mysql][:bind_address],

      # Fine Tuning
      :key_buffer => node[:db_mysql][:tunable][:key_buffer],
      :thread_cache_size => node[:db_mysql][:tunable][:thread_cache_size],
      :max_connections => node[:db_mysql][:tunable][:max_connections],
      :wait_timeout => node[:db_mysql][:tunable][:wait_timeout],
      :net_read_timeout => node[:db_mysql][:tunable][:net_read_timeout],
      :net_write_timeout => node[:db_mysql][:tunable][:net_write_timeout],
      :back_log => node[:db_mysql][:tunable][:back_log],
      :table_cache => node[:db_mysql][:tunable][:table_cache],
      :max_heap_table_size => node[:db_mysql][:tunable][:max_heap_table_size],
      :sort_buffer_size => node[:db_mysql][:tunable][:sort_buffer_size],
      :read_buffer_size => node[:db_mysql][:tunable][:read_buffer_size],
      :read_rnd_buffer_size => node[:db_mysql][:tunable][:read_rnd_buffer_size],
      :myisam_sort_buffer_size =>
        node[:db_mysql][:tunable][:myisam_sort_buffer_size],
      :net_buffer_length => node[:db_mysql][:tunable][:net_buffer_length],

      # Query Cache Configuration
      :query_cache_size => node[:db_mysql][:tunable][:query_cache_size],

      # Logging and Replication
      :log => node[:db_mysql][:log],
      :log_error => node[:db_mysql][:log_error],
      :log_slow_queries => node[:db_mysql][:tunable][:log_slow_queries],
      :long_query_time => node[:db_mysql][:tunable][:long_query_time],
      :read_only => node[:db_mysql][:tunable][:read_only],
      :server_id => params[:server_id],
      :log_bin_enabled => node[:db_mysql][:log_bin_enabled],
      :log_bin => node[:db_mysql][:log_bin],
      :expire_logs_days => node[:db_mysql][:tunable][:expire_logs_days],
      :binlog_format => node[:db_mysql][:binlog_format],

      # InnoDB
      :innodb_buffer_pool_size =>
        node[:db_mysql][:tunable][:innodb_buffer_pool_size],
      :innodb_additional_mem_pool_size =>
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size],
      :innodb_log_file_size => params[:innodb_log_file_size] ||
        node[:db_mysql][:tunable][:innodb_log_file_size],
      :innodb_log_buffer_size =>
        node[:db_mysql][:tunable][:innodb_log_buffer_size],
      :data_dir => node[:db][:data_dir],
      :relay_log => params[:relay_log],

      :compressed_protocol => params[:compressed_protocol] ? "1" : "0",

      # SSL
      :ssl_enabled => node[:db_mysql][:ssl_enabled],
      :ca_certificate =>
        node[:db_mysql][:ssl_credentials][:ca_certificate][:path],
      :master_certificate =>
        node[:db_mysql][:ssl_credentials][:master_certificate][:path],
      :master_key => params[:master_key]||
        node[:db_mysql][:ssl_credentials][:master_key][:path],
      :version => node[:db][:version],

      :isamchk_key_buffer => node[:db_mysql][:tunable][:isamchk][:key_buffer],
      :isamchk_sort_buffer_size =>
        node[:db_mysql][:tunable][:isamchk][:sort_buffer_size]
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
