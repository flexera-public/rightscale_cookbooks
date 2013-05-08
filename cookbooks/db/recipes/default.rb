#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

# If block_device is used, set that to be node[:db][:data_dir]
# See cookbooks/block_device/libraries/block_device.rb for the "get_device_or_default" method.
device = get_device_or_default(node, node[:block_device])
if device
  mount_point = node[:block_device][:devices][:device1][:mount_point] if node[:block_device][:devices].include?(:device1)
  if !mount_point.nil? && !mount_point.empty?
    node[:db][:data_dir] = mount_point
  end
end

# If node[:db][:provider_type] has a value we assume that db::default is
# executed on client server and the value has been setup using
# db/provider_type input. In that case, use this value to setup provider for
# 'db' resource and database version.
#
provider_type = node[:db][:provider_type]
if not provider_type.empty?
  database_type = provider_type.match(/^db_([a-z]+)_(\d.\d)/)
  # Database provider type Ex: db_mysql
  node[:db][:provider] = "db_#{database_type[1]}"
  # Database version number Ex: 5.1
  node[:db][:version] = database_type[2]
end

# Setup default values for database resource
# See cookbooks/db_<provider>/providers/default.rb for the "install_client" action.
db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  db_version node[:db][:version]
  action :install_client
end
