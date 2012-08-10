#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# If block_device is used, set that to be node[:db][:data_dir]
#mount_point = node[:block_device][:devices][:device1][:mount_point]
#if !mount_point.nil? && !mount_point.empty?
#  node[:db][:data_dir] = mount_point
#end

# Setup default values for database resource
db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  action :nothing
end

include_recipe "db::install_client"

rightscale_marker :end
