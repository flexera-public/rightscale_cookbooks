#
# Cookbook Name:: block_device
#
# Copyright 2011, RightScale, Inc.
#
# All rights reserved - Do Not Redistribute
#

# Detach and delete volumes and then terminate the server.
# This recipe ensures that the volume is deleted prior to the instance
# being terminated
#
rightscale_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

raise "Server terminate saftey not off.  Override block_device/terminate_safety to run this recipe" unless node[:block_device][:terminate_safety] == "off"

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
