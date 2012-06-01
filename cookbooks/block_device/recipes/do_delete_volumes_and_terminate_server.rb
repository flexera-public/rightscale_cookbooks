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

raise "Server terminate safety not off.  Override block_device/terminate_safety to run this recipe" unless node[:block_device][:terminate_safety] == "off"

log "  Detach and delete volume..."
do_for_all_block_devices node[:block_device] do |device|
  block_device get_device_or_default(node, device, :nickname) do
    action :reset
  end
end

log "  Shutdown immediate"
rs_shutdown "Terminate the server now" do
  # And shutdown regardless of any errors.
  immediately true
  action :terminate
end

rightscale_marker :end
