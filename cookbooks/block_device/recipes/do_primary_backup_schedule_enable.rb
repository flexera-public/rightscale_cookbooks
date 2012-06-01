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
    command "rs_run_recipe -j '#{block_device_json}' -n 'block_device::do_primary_backup' 2>&1 > /var/log/rightscale_tools_cron_backup_block_device_#{device}.log"
    action :create
  end
end

rightscale_marker :end
