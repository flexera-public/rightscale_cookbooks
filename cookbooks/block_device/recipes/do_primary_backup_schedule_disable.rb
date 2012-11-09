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

# Disable backup schedule.
# Remove JSON files /var/lib/rightscale_block_device_#{device}.json which
# is used by the cron jobs for scheduling backups and delete the cron jobs.
# See cookbooks/block_device/libraries/block_device.rb for the definition of
# do_for_block_devices.
#
do_for_block_devices node[:block_device] do |device|
  file "/var/lib/rightscale_block_device_#{device}.json" do
    action :delete
    backup false
  end

  cron "RightScale continuous primary backups for device #{device}" do
    user "root"
    action :delete
  end
end

rightscale_marker :end
