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

# Backs up the block device to a secondary cloud storage provider (ROS based).
# Specify backup lineage to which the device should be backed up and the
# secondary cloud credentials. See cookbooks/block_device/providers/default.rb
# for implementation of "snapshot" and "secondary_backup actions". See
# cookbooks/block_device/libraries/default.rb for "do_for_block_devices" and
# "get_device_or_default" methods.
#
do_for_block_devices node[:block_device] do |device|
  backup_lineage = get_device_or_default(node, device, :backup, :lineage)
  log "======== LINEAGE ========="
  log backup_lineage
  log "======== LINEAGE ========="

  log "  Creating snapshot for device #{device}..."
  nickname = get_device_or_default(node, device, :nickname)
  block_device nickname do
    action :snapshot
  end

  block_device nickname do
    # Backup/Restore arguments
    lineage backup_lineage

    secondary_cloud get_device_or_default(node, device, :backup, :secondary, :cloud)
    secondary_endpoint get_device_or_default(node, device, :backup, :secondary, :endpoint) || ""
    secondary_container get_device_or_default(node, device, :backup, :secondary, :container)
    secondary_user get_device_or_default(node, device, :backup, :secondary, :cred, :user)
    secondary_secret get_device_or_default(node, device, :backup, :secondary, :cred, :secret)

    action :secondary_backup
  end
end

rightscale_marker :end
