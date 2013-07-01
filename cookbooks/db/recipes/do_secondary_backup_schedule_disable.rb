#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

# See cookbooks/block_device/libraries/block_device.rb
# for the "get_device_or_default" method.
NICKNAME = get_device_or_default(node, :device1, :nickname)

# See cookbooks/block_device/providers/default.rb
# for the "backup_schedule_disable" action.
block_device NICKNAME do
  cron_backup_recipe "#{self.cookbook_name}::do_secondary_backup"
  action :backup_schedule_disable
end
