#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Detailed descriptions of variables below can be found in block_device/metadata.rb file
set_unless[:block_device][:devices][:default][:backup][:lineage] = ""
set_unless[:block_device][:devices][:default][:backup][:lineage_override] = ""

set_unless[:block_device][:devices][:default][:backup][:primary][:keep][:max_snapshots] = "60"

set_unless[:block_device][:devices][:default][:backup][:primary][:cloud] = 'cloudfiles' if cloud[:provider] == 'rackspace'

set_unless[:block_device][:devices][:default][:backup][:primary][:cred][:user] = ""
set_unless[:block_device][:devices][:default][:backup][:primary][:cred][:secret] = ""

set_unless[:block_device][:devices][:default][:backup][:secondary][:cred][:user] = ""
set_unless[:block_device][:devices][:default][:backup][:secondary][:cred][:secret] = ""

set_unless[:block_device][:devices_to_use] = 'device1'

# Defining initial backup parameters for all block devices
RightScale::BlockDeviceHelper.do_for_all_block_devices block_device do |device, number|
  # Backup every hour on a randomly calculated minute
  set_unless[:block_device][:devices][device][:backup][:primary][:cron][:hour] = "*" # Every hour
  set_unless[:block_device][:devices][device][:backup][:primary][:cron][:minute] = "#{5+rand(50)}"

  set_unless[:block_device][:devices][device][:mount_point] = "/mnt/storage#{number}"
  set_unless[:block_device][:devices][device][:vg_data_percentage] = "90"
  set_unless[:block_device][:devices][device][:nickname] = "data_storage#{number}"
end
