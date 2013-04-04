#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

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

  ruby_block "mysql_tuning" do
    block do
      class Chef::Resource::RubyBlock
        include RightScale::Database::Helper
      end

      # Sets tuning parameters in the my.cnf file.
      #
      # Shared servers get %50 of the resources allocated to a dedicated server.
      usage = node[:db_mysql][:server_usage] == "shared" ? 0.5 : 1

      # We are working with MB. Set GB so X * GB can be used in conditional.
      GB = 1024

      # Converts memory from kB to MB.
      mem = node[:memory][:total].to_i / 1024
      Chef::Log.info "  Auto-tuning MySQL parameters. Total memory: #{mem}M"

      node[:db_mysql][:tunable][:query_cache_size] =
        value_with_units((mem * 0.01).to_i, "M", usage)
      Chef::Log.info "  Setting query_cache_size" +
        " to: #{node[:db_mysql][:tunable][:query_cache_size]}"

      node[:db_mysql][:tunable][:innodb_buffer_pool_size] =
        value_with_units((mem * 0.8).to_i, "M", usage)
      Chef::Log.info "  Setting innodb_buffer_pool_size" +
        " to: #{node[:db_mysql][:tunable][:innodb_buffer_pool_size]}"

      # Fixed parameters, common value for all instance sizes
      #
      # These parameters may be too large for very small instance sizes
      # with < 1gb memory.
      node[:db_mysql][:tunable][:thread_cache_size] = (50 * usage).to_i
      node[:db_mysql][:tunable][:max_connections] = (800 * usage).to_i
      node[:db_mysql][:tunable][:wait_timeout] = (28800 * usage).to_i
      node[:db_mysql][:tunable][:net_read_timeout] = (30 * usage).to_i
      node[:db_mysql][:tunable][:net_write_timeout] = (30 * usage).to_i
      node[:db_mysql][:tunable][:back_log] = (128 * usage).to_i
      node[:db_mysql][:tunable][:max_heap_table_size] =
        value_with_units(32, "M", usage)
      node[:db_mysql][:tunable][:net_buffer_length] =
        value_with_units(16, "K", usage)
      node[:db_mysql][:tunable][:read_buffer_size] =
        value_with_units(1, "M", usage)
      node[:db_mysql][:tunable][:read_rnd_buffer_size] =
        value_with_units(4, "M", usage)
      node[:db_mysql][:tunable][:log_slow_queries] =
        "log_slow_queries = /var/log/mysqlslow.log"
      node[:db_mysql][:tunable][:long_query_time] = "long_query_time = 5"
      node[:db_mysql][:tunable][:slave_net_timeout] = 60

      # Adjust based on memory range.
      #
      # The memory ranges used are:
      # < 1GB, 1GB - 3GB, 3GB - 10GB, 10GB - 25GB, 25GB - 50GB, > 50GB.
      if mem < 1 * GB
        # Override buffer sizes for really small servers
        node[:db_mysql][:tunable][:key_buffer] =
          value_with_units(16, "M", usage)
        node[:db_mysql][:tunable][:isamchk][:key_buffer] =
          value_with_units(20, "M", usage)
        node[:db_mysql][:tunable][:isamchk][:sort_buffer_size] =
          value_with_units(20, "M", usage)
        node[:db_mysql][:tunable][:myisamchk][:key_buffer] =
          value_with_units(20, "M", usage)
        node[:db_mysql][:tunable][:myisamchk][:sort_buffer_size] =
          value_with_units(20, "M", usage)
        node[:db_mysql][:tunable][:innodb_log_file_size] =
          value_with_units(4, "M", usage)
        node[:db_mysql][:tunable][:innodb_log_buffer_size] =
          value_with_units(16, "M", usage)
      else
        node[:db_mysql][:tunable][:key_buffer] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:tunable][:isamchk][:key_buffer] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:tunable][:isamchk][:sort_buffer_size] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:tunable][:myisamchk][:key_buffer] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:tunable][:myisamchk][:sort_buffer_size] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:tunable][:innodb_log_file_size] =
          value_with_units(64, "M", usage)
        node[:db_mysql][:tunable][:innodb_log_buffer_size] =
          value_with_units(8, "M", usage)
      end

      if mem < 3 * GB
        node[:db_mysql][:tunable][:table_cache] = (256 * usage).to_i
        node[:db_mysql][:tunable][:sort_buffer_size] =
          value_with_units(2, "M", usage)
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size] =
          value_with_units(50, "M", usage)
        node[:db_mysql][:tunable][:myisam_sort_buffer_size] =
          value_with_units(64, "M", usage)
        node[:db_mysql][:init_timeout] ||= (600 * usage).to_i
      elsif mem < 10 * GB
        node[:db_mysql][:tunable][:table_cache] = (512 * usage).to_i
        node[:db_mysql][:tunable][:sort_buffer_size] =
          value_with_units(4, "M", usage)
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size] =
          value_with_units(200, "M", usage)
        node[:db_mysql][:tunable][:myisam_sort_buffer_size] =
          value_with_units(96, "M", usage)
        node[:db_mysql][:init_timeout] ||= (1200 * usage).to_i
      elsif mem < 25 * GB
        node[:db_mysql][:tunable][:table_cache] = (1024 * usage).to_i
        node[:db_mysql][:tunable][:sort_buffer_size] =
          value_with_units(8, "M", usage)
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size] =
          value_with_units(300, "M", usage)
        node[:db_mysql][:tunable][:myisam_sort_buffer_size] =
          value_with_units(128, "M", usage)
        node[:db_mysql][:init_timeout] ||= (1800 * usage).to_i
      elsif mem < 50 * GB
        node[:db_mysql][:tunable][:table_cache] = (2048 * usage).to_i
        node[:db_mysql][:tunable][:sort_buffer_size] =
          value_with_units(16, "M", usage)
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size] =
          value_with_units(400, "M", usage)
        node[:db_mysql][:tunable][:myisam_sort_buffer_size] =
          value_with_units(256, "M", usage)
        node[:db_mysql][:init_timeout] ||= (2400 * usage).to_i
      else
        node[:db_mysql][:tunable][:table_cache] = (4096 * usage).to_i
        node[:db_mysql][:tunable][:sort_buffer_size] =
          value_with_units(32, "M", usage)
        node[:db_mysql][:tunable][:innodb_additional_mem_pool_size] =
          value_with_units(500, "M", usage)
        node[:db_mysql][:tunable][:myisam_sort_buffer_size] =
          value_with_units(512, "M", usage)
        node[:db_mysql][:init_timeout] ||= (3000 * usage).to_i
      end
    end
  end

  log "  Installing my.cnf with server_id = #{params[:server_id]}," +
    " relay_log = #{params[:relay_log]}"

  template "/etc/mysql/conf.d/my.cnf" do
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
