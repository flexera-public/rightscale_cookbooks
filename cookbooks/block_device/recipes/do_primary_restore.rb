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

# In this code block, we restore snapshot from a lineage specified by
# "lineage" attribute. We can override that lineage by specifying
# "device/lineage_override" input. If device/timestamp_override input is set,
# the snapshot from that timestamp in the lineage will be restored. Else
# the snapshot with the most recent timestamp will be restored.
# See cookbooks/block_device/providers/default.rb for definition of
# primary_restore action and cookbooks/block_device/libraries/block_device.rb
# for definition of "do_for_block_devices", "set_restore_params" and "get_device_or_default" methods.
#
do_for_block_devices node[:block_device] do |device|

  # Do the restore.
  log "  Creating block device and restoring data from primary backup for device #{device}..."
  restore_lineage, restore_timestamp_override = set_restore_params(
    get_device_or_default(node, device, :backup, :lineage),
    get_device_or_default(node, device, :backup, :lineage_override),
    get_device_or_default(node, device, :backup, :timestamp_override)
  )

  block_device get_device_or_default(node, device, :nickname) do
    # Backup/Restore arguments
    lineage restore_lineage
    timestamp_override restore_timestamp_override
    action :primary_restore
  end
end
