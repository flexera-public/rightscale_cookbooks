#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

# Set up and create a block device. If node[:block_device][:devices_to_use]
# is set to '*', then this code block will create a block device for each
# device. See cookbooks/block_device/libraries/block_device.rb for the
# definition of "do_for_block_devices" and "get_device_or_default" methods.
# See cookbooks/block_device/providers/default.rb for "action :create"
# implementation.
#
do_for_block_devices node[:block_device] do |device|
  block_device get_device_or_default(node, device, :nickname) do
    mount_point get_device_or_default(node, device, :mount_point)

    # Optional cloud variables
    volume_size get_device_or_default(node, device, :volume_size)
    stripe_count get_device_or_default(node, device, :stripe_count)
    vg_data_percentage get_device_or_default(node, device, :vg_data_percentage)
    iops get_device_or_default(node, device, :iops) || ""
    volume_type get_device_or_default(node, device, :volume_type)

    action :create
  end
end
