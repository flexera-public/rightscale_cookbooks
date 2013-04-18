#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

require 'uri'

# = Block_device Attributes
#
# Below are the attributes defined by the block_device resource interface.
#

# == General options

# Block device nickname
#
attribute :nickname, :kind_of => String, :name_attribute => true

# Cloud on which the instance is launched
#
attribute :cloud, :required => true

# Hypervisor implemented by the cloud
#
attribute :hypervisor, :kind_of => String

# Block device mount point
#
attribute :mount_point, :kind_of => String, :required => true

# Check if the block device is the master
#
attribute :is_master, :equal_to => [true, false], :default => false

# Force backups on a device
#
attribute :force, :equal_to => [true, false], :default => false

# == Backup/Restore options

# Backup lineage for a block device
#
attribute :lineage, :kind_of => String

# Override default timestamp on a block device backup
#
attribute :timestamp_override, :kind_of => String # Restore only


# == Primary backup schedule options

# Minute value to specify in cron job
#
attribute :cron_backup_minute, :kind_of => String

# Hour value to specify in cron job
#
attribute :cron_backup_hour, :kind_of => String

# Recipe executed via cron job
#
attribute :cron_backup_recipe,
  :kind_of => String,
  :default => "block_device::do_backup"


# == Rotation options

# Maximum snapshots to keep for a block device
#
attribute :max_snapshots, :kind_of => String

# Number of daily snapshots to be be kept
#
attribute :keep_daily, :kind_of => String

# Number of weekly snapshots to be kept
#
attribute :keep_weekly, :kind_of => String

# Number of monthly snapshots to be kept
#
attribute :keep_monthly, :kind_of => String

# Number of yearly snapshots to be kept
#
attribute :keep_yearly, :kind_of => String


# == Options for volume block devices

# Size of the block device
#
attribute :volume_size, :kind_of => String

# Number of stripes to be created on a block device
#
attribute :stripe_count, :kind_of => String

# Percentage allocated for data on a block device
#
attribute :vg_data_percentage, :kind_of => String

# Set IOPS value for a block device. Only available on EC2 clouds
#
attribute :iops, :kind_of => String

# Type of the block device
#
attribute :volume_type,
  :kind_of => String,
  :equal_to => ["SATA", "SSD"],
  :default => "SATA"

# == Callbacks for ROS endpoint validation
endpoint_callbacks = {
  "invalid endpoint URL" => Proc.new do |value|
    begin
      value.empty? || URI.parse(value).is_a?(URI::HTTP)
    rescue URI::InvalidURIError
      false
    end
  end
}

# == Options for Remote Object Store

# Cloud used for primary backup
#
attribute :primary_cloud, :kind_of => String

# Endpoint for the primary cloud
#
attribute :primary_endpoint,
  :kind_of => String,
  :callbacks => endpoint_callbacks

# Username for primary cloud
#
attribute :primary_user, :kind_of => String

# Secret key for primary cloud
#
attribute :primary_secret, :kind_of => String


# == Secondary backup options

# Cloud used for secondary backup (ROS backup)
#
attribute :secondary_cloud, :kind_of => String

# Endpoint for the secondary cloud
#
attribute :secondary_endpoint,
  :kind_of => String,
  :callbacks => endpoint_callbacks

# ROS container name on the secondary cloud
#
attribute :secondary_container, :kind_of => String

# Username for the secondary cloud
#
attribute :secondary_user, :kind_of => String

# Secret key for the secondary cloud
#
attribute :secondary_secret, :kind_of => String


# == Cloud specific options

# Enable/Disable SNET for Rackspace cloud
#
attribute :rackspace_snet, :equal_to => [true, false], :default => true


# = General Block_device Actions
#
# Below are the actions defined by the block_device resource interface.
#


# This utility creates a new block device.
#
actions :create

# This action will create a snapshot of a block device previously created
#
actions :snapshot

# Prepare device for primary backup
#
actions :primary_backup

# Prepare device for primary restore
#
actions :primary_restore

# Prepare device for secondary backup
#
actions :secondary_backup

# Prepare device for secondary restore
#
actions :secondary_restore

# Unmount and delete the attached block device(s)
#
actions :reset

# Enable cron-based scheduled backups
#
actions :backup_schedule_enable

# Disable cron-based scheduled backups
#
actions :backup_schedule_disable
