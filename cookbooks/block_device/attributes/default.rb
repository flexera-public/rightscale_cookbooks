#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Detailed descriptions of variables below can be found in block_device/metadata.rb file
default[:block_device][:devices][:default][:backup][:lineage] = ""
default[:block_device][:devices][:default][:backup][:lineage_override] = ""

default[:block_device][:devices][:default][:backup][:primary][:keep][:max_snapshots] = "60"

default[:block_device][:devices][:default][:backup][:primary][:cloud] = 
  'Cloud_Files' if cloud[:provider] == 'rackspace'

# Defining initial backup parameters for all block devices
RightScale::BlockDeviceHelper.do_for_all_block_devices block_device do |device, number|
  # Backup every hour on a randomly calculated minute
  default[:block_device][:devices][device][:backup][:primary][:cron][:hour] = "*" # Every hour
  default[:block_device][:devices][device][:backup][:primary][:cron][:minute] = "#{5+rand(50)}"

  default[:block_device][:devices][device][:mount_point] = "/mnt/storage#{number}"
  default[:block_device][:devices][device][:vg_data_percentage] = "90"
  default[:block_device][:devices][device][:nickname] = "data_storage#{number}"
end

# block_device/first_server_uuid will be used to generate unique block device nicknames
default[:block_device][:first_server_uuid] = node[:rightscale][:instance_uuid]

# Recommended attributes

# Block device(s) to operate on
default[:block_device][:devices_to_use] = "device1"
# Primary backup user
default[:block_device][:devices][:default][:backup][:primary][:cred][:user] = ""
# Primary backup secret
default[:block_device][:devices][:default][:backup][:primary][:cred][:secret] = ""
# Secondary backup user
default[:block_device][:devices][:default][:backup][:secondary][:cred][:user] = ""
# Secondary backup secret
default[:block_device][:devices][:default][:backup][:secondary][:cred][:secret] = ""
# Secondary backup storage cloud
default[:block_device][:devices][:default][:backup][:secondary][:cloud] = ""
# Terminate safety flag
default[:block_device][:terminate_safety] = "Override the dropdown and set" +
  " to \"off\" to really run this recipe"
# Force reset safety flag
default[:block_device][:force_safety] = "Override the dropdown and set to" +
  " \"off\" to really run this recipe"

# Optional attributes

# Primary backup storage cloud
default[:block_device][:devices][:default][:backup][:primary][:cloud] = ""
# Primary backup storage cloud endpoint URL
default[:block_device][:devices][:default][:backup][:primary][:endpoint] = ""
# Secondary backup storage cloud endpoint URL
default[:block_device][:devices][:default][:backup][:secondary][:endpoint] = ""
# Rackspace SNET enabled for backup
default[:block_device][:devices][:default][:backup][:rackspace_snet] = "true"
# Percentage of the ephemeral LVM used for data
default[:block_device][:ephemeral][:vg_data_percentage] = "100"
# Type of file system set up on ephemeral devices
default[:block_device][:ephemeral][:file_system_type] = "xfs"

# Multiple Block Devices
device_count = 2
devices = 1.upto(device_count).map { |number| "device#{number}" }

# Set up the block device attributes for each device
devices.sort.each_with_index.map do |device, index|
  [device, index + 1]
end.each do |device, number|
  default[:block_device][:devices][device][:stripe_count] = "1"
  default[:block_device][:devices][device][:volume_size] = "10"
  default[:block_device][:devices][device][:backup][:lineage] = ""
  default[:block_device][:devices][device][:nickname] = "data_storage#{number}"
  default[:block_device][:devices][device][:backup][:lineage_override] = ""
  default[:block_device][:devices][device][:backup][:timestamp_override] = ""
  default[:block_device][:devices][device][:backup][:primary][:cron][:minute] = ""
  default[:block_device][:devices][device][:backup][:primary][:cron][:hour] = ""
  default[:block_device][:devices][device][:backup][:primary][:keep][:max_snapshots] = "60"
  default[:block_device][:devices][device][:backup][:primary][:keep][:daily] = "14"
  default[:block_device][:devices][device][:backup][:primary][:keep][:weekly] = "6"
  default[:block_device][:devices][device][:backup][:primary][:keep][:monthly] = "12"
  default[:block_device][:devices][device][:backup][:primary][:keep][:yearly] = "2"
  default[:block_device][:devices][device][:backup][:secondary][:container] = ""
  default[:block_device][:devices][device][:mount_point] = "/mnt/storage#{number}"
  default[:block_device][:devices][device][:iops] = ""
  default[:block_device][:devices][device][:volume_type] = "SATA"
end
