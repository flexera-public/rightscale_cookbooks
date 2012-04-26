#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

do_for_block_devices node[:block_device] do |device|
  if get_device_or_default(node, device, :backup, :lineage_override).empty?
    backup_lineage = get_device_or_default(node, device, :backup, :lineage)
  else
    log "** USING LINEAGE OVERRIDE **"
    backup_lineage = get_device_or_default(node, device, :backup, :lineage_override)
  end

  log "======== LINEAGE ========="
  log backup_lineage
  log "======== LINEAGE ========="

  # Do the restore.
  log "  Creating block device and restoring data from secondary backup for device #{device}..."
  block_device get_device_or_default(node, device, :nickname) do
    # Backup/Restore arguments
    lineage backup_lineage
    lineage_override get_device_or_default(node, device, :backup, :lineage_override)
    timestamp_override get_device_or_default(node, device, :backup, :timestamp_override)

    secondary_cloud get_device_or_default(node, device, :backup, :secondary, :cloud)
    secondary_endpoint get_device_or_default(node, device, :backup, :secondary, :endpoint)
    secondary_container get_device_or_default(node, device, :backup, :secondary, :container)
    secondary_user get_device_or_default(node, device, :backup, :secondary, :cred, :user)
    secondary_secret get_device_or_default(node, device, :backup, :secondary, :cred, :secret)

    action :secondary_restore
  end
end

rs_utils_marker :end
