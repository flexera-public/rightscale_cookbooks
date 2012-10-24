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

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

# Similar to primary_restore, we set the lineage and timestamp override tnputs
# to choose snapshot to be restored. Set up secondary cloud credentials from
# which the snapshot needs to be retrieved.
# See block_device/providers/default.rb for secondary_restore action
# implementation and block_device/libraries/block_device.rb for
# do_for_block_devices and get_device_or_default
#
do_for_block_devices node[:block_device] do |device|
  # Do the restore.
  log "  Creating block device and restoring data from secondary backup for device #{device}..."
  lineage = get_device_or_default(node, device, :backup, :lineage)
  lineage_override = get_device_or_default(node, device, :backup, :lineage_override)
  restore_lineage = lineage_override == nil || lineage_override.empty? ? lineage : lineage_override
  restore_timestamp_override = get_device_or_default(node, device, :backup, :timestamp_override)
  log "  Input lineage #{restore_lineage.inspect}"
  log "  Input lineage_override #{lineage_override.inspect}"
  log "  Using lineage #{restore_lineage.inspect}"
  log "  Input timestamp_override #{restore_timestamp_override.inspect}"
  restore_timestamp_override ||= ""

  block_device get_device_or_default(node, device, :nickname) do
    # Backup/Restore arguments
    lineage restore_lineage
    timestamp_override restore_timestamp_override

    secondary_cloud get_device_or_default(node, device, :backup, :secondary, :cloud)
    secondary_endpoint get_device_or_default(node, device, :backup, :secondary, :endpoint) || ""
    secondary_container get_device_or_default(node, device, :backup, :secondary, :container)
    secondary_user get_device_or_default(node, device, :backup, :secondary, :cred, :user)
    secondary_secret get_device_or_default(node, device, :backup, :secondary, :cred, :secret)

    action :secondary_restore
  end
end

rightscale_marker :end
