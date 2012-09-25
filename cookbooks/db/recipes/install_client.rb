#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin
database_type = node[:db][:provider_type].match(/^db_([a-z]+)_(\d.\d)/)

# If node[:db][:provider] and node[:db][:version] have values
# we assume that db::install_client is executed on Database Manager
# and using values from db_*::default_* recipe (ex: db_mysql::default_5_1)
#
# If node[:db][:provider] and node[:db][:version]  have no values
# we assume that db::install_client is executed on Application Server
# and setup their values using db/provider_type input.
#
# Database provider type Ex: db_mysql
node[:db][:provider] = "db_#{database_type[1]}" if node[:db][:provider].nil?
# Database version number Ex: 5.1
node[:db][:version] = database_type[2] if node[:db][:version].nil?

db node[:db][:data_dir] do
  db_version node[:db][:version]
  provider node[:db][:provider]
  action :install_client
  persist true
end

rightscale_marker :end
