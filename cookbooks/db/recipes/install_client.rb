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
if node[:db][:provider] == ""
  node[:db][:provider] = "db_#{database_type[0]}"
end
# Database version number Ex: 5.1
database_version = database_type[1]

db node[:db][:data_dir] do
  db_version database_version
  provider node[:db][:provider]
  action :install_client
  persist true
end

rightscale_marker :end
