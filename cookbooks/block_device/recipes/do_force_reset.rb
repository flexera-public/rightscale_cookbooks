#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

# Try and return the instance to a launch/pristine state
# For development and testing.  Not intended for use on production servers.

raise "Server force safety not off.  Override block_device/force_safety to run this recipe" unless node[:block_device][:force_safety] == "off"

do_for_block_devices node[:block_device] do |device|
  # Clear the overrides so they are not set after a reset is done
  node[:block_device][:devices][device][:backup][:lineage_override] = ""
  node[:block_device][:devices][device][:backup][:timestamp_override] = ""
  block_device get_device_or_default(node, device, :nickname) do
    action :reset
  end
end

rightscale_marker :end
