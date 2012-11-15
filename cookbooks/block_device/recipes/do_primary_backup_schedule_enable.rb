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

# To enable continuous backups, we create JSON file for each block device under
# /var/lib/rightscale_block_device_#{device}.json. JSON file will have all the
# resource attributes set up for the device. We initiate a cron job to schedule
# primary backups. Time parameters for cron job are obtained from
# "cron_backup_minute" and "cron_backup_hour" attributes defined in
# cookbooks/block_device/resources/default.rb.
# See cookbooks/block_device/libraries/default.rb for definitions of
# "do_for_block_devices" and "get_device_or_default" methods.
#
do_for_block_devices node[:block_device] do |device|
  log "  Enabling continuous backups for device #{device} via cron job:#{get_device_or_default(node, device, :backup, :primary, :cron, :minute)} #{get_device_or_default(node, device, :backup, :primary, :cron, :hour)}"

  block_device_json = "/var/lib/rightscale_block_device_#{device}.json"

  file block_device_json do
    owner 'root'
    group 'root'
    mode 0644
    content JSON.dump({:block_device => {:devices_to_use => device}})
    backup false
  end

  cron_minute = get_device_or_default(node, device, :backup, :primary, :cron, :minute).to_s
  cron_hour = get_device_or_default(node, device, :backup, :primary, :cron, :hour).to_s

  cron "RightScale continuous primary backups for device #{device}" do
    minute cron_minute unless cron_minute.empty?
    hour cron_hour unless cron_hour.empty?
    user "root"
    command "rs_run_recipe --json '#{block_device_json}' --policy 'block_device::do_primary_backup' --name 'block_device::do_primary_backup' 2>&1 >> /var/log/rightscale_tools_cron_backup_block_device_#{device}.log"
    action :create
  end
end

rightscale_marker :end
