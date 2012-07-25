#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

db node[:db][:data_dir] do
  action :setup_monitoring
end

# Creating a db backup info file
file "/mnt/storage/db_sys_info.log" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "uname" do
  command "echo \"System information:\n\" > /mnt/storage/db_sys_info.log && uname -a >> /mnt/storage/db_sys_info.log"
  action :run
end

execute "lsb_release" do
  command "lsb_release -a >> /mnt/storage/db_sys_info.log"
  action :run
end

execute "mysql" do
  command "echo \"\nMySQL information:\n\" >> /mnt/storage/db_sys_info.log && mysql -V >> /mnt/storage/db_sys_info.log"
  action :run
end

rightscale_marker :end
