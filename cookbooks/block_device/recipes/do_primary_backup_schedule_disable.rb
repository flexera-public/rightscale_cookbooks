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

rs_utils_marker :end
