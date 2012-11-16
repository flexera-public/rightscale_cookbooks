#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_mysql_set_mycnf_read_only, :read_only => false do

  read_only = params[:read_only] ? 1 : 0
  log "  Installing read_write_status.cnf with read_only = #{read_only}"

  template value_for_platform("default" => "/etc/mysql/conf.d/read_write_status.cnf") do
    source "read_write_status.cnf.erb"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :read_only => read_only
    )
    cookbook "db_mysql"
  end

  # No need to do a restart - this is only called to update the config file and
  # not change the running daemons read/write status.
end
