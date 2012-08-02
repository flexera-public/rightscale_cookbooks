#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_set_mycnf, :server_id => nil, :relay_log => nil, :innodb_log_file_size => nil do

  log "  Installing my.cnf with server_id = #{params[:server_id]}, relay_log = #{params[:relay_log]}" 
  template value_for_platform("default" => "/etc/mysql/conf.d/my.cnf") do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :server_id => params[:server_id],
      :relay_log => params[:relay_log],
      :innodb_log_file_size => params[:innodb_log_file_size] || node[:db_mysql][:tunable][:innodb_log_file_size]
    )
    cookbook "db_mysql"
  end

end
