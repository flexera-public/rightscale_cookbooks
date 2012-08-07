#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Initial setting for data directory location.
# This extracts the database name from the provider and creates a directory with that name in the mount point
node[:db][:data_dir] = "#{node[:block_device][:devices][:device1][:mount_point]}/#{node[:db][:provider].split('_')[1]}"

# Setup default values for database resource
db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  action :nothing
end

include_recipe "db::install_client"

rightscale_marker :end
