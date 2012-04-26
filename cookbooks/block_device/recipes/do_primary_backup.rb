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
  log "  Creating snapshot of device #{device}..."
  nickname = get_device_or_default(node, device, :nickname)
  block_device nickname do
    action :snapshot
  end

  log "  Starting primary backup of device #{device}..."
  lineage = get_device_or_default(node, device, :backup, :lineage)
  block_device nickname do
    # Backup/Restore arguments
    lineage lineage
    max_snapshots get_device_or_default(node, device, :backup, :primary, :keep, :max_snapshots)
    keep_daily get_device_or_default(node, device, :backup, :primary, :keep, :daily)
    keep_weekly get_device_or_default(node, device, :backup, :primary, :keep, :weekly)
    keep_monthly get_device_or_default(node, device, :backup, :primary, :keep, :monthly)
    keep_yearly get_device_or_default(node, device, :backup, :primary, :keep, :yearly)

    action :primary_backup
  end
end

rs_utils_marker :end
