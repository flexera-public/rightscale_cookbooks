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

do_for_block_devices node[:block_device] do |device|
  # Do the restore.
  log "  Creating block device and restoring data from primary backup for device #{device}..."
  lineage = get_device_or_default(node, device, :backup, :lineage)
  lineage_override = get_device_or_default(node, device, :backup, :lineage_override)
  restore_lineage = lineage_override == nil || lineage_override.empty? ? lineage : lineage_override
  log "  Input lineage #{restore_lineage}"
  log "  Input lineage_override #{lineage_override}"
  log "  Using lineage #{restore_lineage}"

  block_device get_device_or_default(node, device, :nickname) do
    # Backup/Restore arguments
    lineage restore_lineage
    timestamp_override get_device_or_default(node, device, :backup, :timestamp_override)

    action :primary_restore
  end
end

rightscale_marker :end
