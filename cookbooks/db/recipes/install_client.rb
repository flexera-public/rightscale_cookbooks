#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin
database_type = node[:db][:database_adapter].match(/(^[a-z]+)_(\d.\d)/)

# Database provider type Ex: db_mysql
# need this conditional to avoid database type collisions on DBMGR
node[:db][:provider] = "db_#{database_type[1]}" if node[:db][:provider].nil? && node[:db][:provider].empty?
# Database version number Ex: 5.1
database_version = database_type[2]

# If block_device is used, set that to be node[:db][:data_dir]
mount_point = node[:block_device][:devices][:device1][:mount_point] if node[:block_device][:devices].include?(:device1)
if !mount_point.nil? && !mount_point.empty?
  node[:db][:data_dir] = mount_point
end

db node[:db][:data_dir] do
  db_version database_version
  provider node[:db][:provider]
  action :install_client
  persist true
end

rightscale_marker :end
