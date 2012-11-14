#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# If block_device is used, set that to be node[:db][:data_dir]
device = get_device_or_default(node, node[:block_device])
if device
  mount_point = node[:block_device][:devices][:device1][:mount_point] if node[:block_device][:devices].include?(:device1)
  if !mount_point.nil? && !mount_point.empty?
    node[:db][:data_dir] = mount_point
  end
end

# Setup default values for database resource
db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  action :nothing
end

include_recipe "db::install_client"

rightscale_marker :end
