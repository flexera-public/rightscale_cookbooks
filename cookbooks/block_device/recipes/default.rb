#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

Gem.clear_paths
require "rightscale_tools"

package "lvm2"

package "xfsprogs" do
  not_if { node[:platform] == "redhat" }
end

log "Inputs volume_size and stripe_count are not used in Rackspace cloud provider. For further information, please visit http://support.rightscale.com/09-Clouds/Rackspace_Hosting#Unsupported_Features" do
  only_if { node[:cloud][:provider] == 'rackspace' }
end

bash "Load kernel modules" do
  flags '-ex'
  code <<-EOS
    modprobe dm_mod
    modprobe dm_snapshot
  EOS
  # These modules are compiled into the kernel on Ubuntu.
  not_if { node[:platform] == "ubuntu" }
  only_if { File.exists?("/proc/modules") }
end

bash "Load xfs kernel module" do
  flags '-ex'
  code 'modprobe xfs'
  not_if { node[:platform] == "redhat" }
  only_if { File.exists?("/proc/modules") }
end

# In this code block, we loop through all block devices listed in
# node[:block_device][:devices] and set up all block device resource attributes
# for each device. See, cookbooks/block_device/resources/default.rb for the
# list of block device resource attributes. We persist the devices at the node
# level so they can be used in other run lists.
# See cookbooks/block_device/libraries/block_device.rb for the definition of
# "do_for_all_block_devices" and "get_device_or_default" methods.
#
do_for_all_block_devices node[:block_device] do |device|
  block_device get_device_or_default(node, device, :nickname) do
    cloud node[:cloud][:provider]

    # Chef 0.10 has 'virtualization/system' while Chef 0.9 had 'virtualization/emulator'
    hypervisor node[:virtualization][:system] || node[:virtualization][:emulator]

    mount_point get_device_or_default(node, device, :mount_point)
    lineage get_device_or_default(node, device, :backup, :lineage)

    max_snapshots get_device_or_default(node, device, :backup, :primary, :keep, :max_snapshots)
    keep_daily get_device_or_default(node, device, :backup, :primary, :keep, :daily)
    keep_weekly get_device_or_default(node, device, :backup, :primary, :keep, :weekly)
    keep_monthly get_device_or_default(node, device, :backup, :primary, :keep, :monthly)
    keep_yearly get_device_or_default(node, device, :backup, :primary, :keep, :yearly)

    # Optional cloud variables
    volume_size get_device_or_default(node, device, :volume_size)
    stripe_count get_device_or_default(node, device, :stripe_count)
    vg_data_percentage get_device_or_default(node, device, :vg_data_percentage)
    iops get_device_or_default(node, device, :iops) || ""
    volume_type get_device_or_default(node, device, :volume_type)

    primary_cloud get_device_or_default(node, device, :backup, :primary, :cloud)
    primary_endpoint get_device_or_default(node, device, :backup, :primary, :endpoint) || ""
    primary_user get_device_or_default(node, device, :backup, :primary, :cred, :user)
    primary_secret get_device_or_default(node, device, :backup, :primary, :cred, :secret)

    # Use snet for cloudfiles on rackspace
    rackspace_snet get_device_or_default(node, device, :backup, :rackspace_snet) == 'true'

    action :nothing

    persist true # store resource to node for use in other run lists
  end
end

rightscale_marker :end
