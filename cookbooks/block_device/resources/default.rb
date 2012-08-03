# 
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

require 'uri'

# Add actions to @action_list array.
# Used to allow comments between entries.
def self.add_action(sym)
  @action_list ||= Array.new
  @action_list << sym unless @action_list.include?(sym)
  @action_list
end


# = Block_device Attributes
# 
# Below are the attributes defined by the block_device resource interface.
#

# == General options
attribute :nickname, :kind_of => String, :name_attribute => true
attribute :cloud, :required => true
attribute :hypervisor, :kind_of => String
attribute :mount_point, :kind_of => String, :required => true
attribute :is_master, :equal_to => [ true, false ], :default => false


# == Backup/Restore options
attribute :lineage, :kind_of => String
attribute :timestamp_override, :kind_of => String # Restore only 

 
# == Primary backup schedule options
attribute :cron_backup_minute, :kind_of => String
attribute :cron_backup_hour, :kind_of => String
attribute :cron_backup_recipe, :kind_of => String, :default => "block_device::do_backup"


# == Rotation options
attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String


# == Options for volume block devices
attribute :volume_size, :kind_of => String
attribute :stripe_count, :kind_of => String
attribute :vg_data_percentage, :kind_of => String

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
attribute :primary_cloud, :kind_of => String
attribute :primary_endpoint, :kind_of => String, :callbacks => endpoint_callbacks
attribute :primary_user, :kind_of => String
attribute :primary_secret, :kind_of => String


# == Secondary backup options
attribute :secondary_cloud, :kind_of => String
attribute :secondary_endpoint, :kind_of => String, :callbacks => endpoint_callbacks
attribute :secondary_container, :kind_of => String
attribute :secondary_user, :kind_of => String
attribute :secondary_secret, :kind_of => String


# == Cloud specific options
attribute :rackspace_snet, :equal_to => [ true, false ], :default => true


# = General Block_device Actions
#
# Below are the actions defined by the block_device resource interface.
#


# == Create
# This utility creates a new block device.
#
add_action :create


# == Snapshot
# This action will create a snapshot of a block device previously created
#
add_action :snapshot


# == Primary Backup
# Prepare device for primary backup
#
add_action :primary_backup


# == Primary Restore
# Prepare device for primary restore
#
add_action :primary_restore


# == Secondary Backup
# Prepare device for secondary backup
#
add_action :secondary_backup


# == Secondary Restore
# Prepare device for secondary restore
#
add_action :secondary_restore


# == Reset
# Unmount and delete the attached block device(s)
#
add_action :reset


# == Backup Schedule Enable
# Enable cron-based scheduled backups
#
add_action :backup_schedule_enable


# == Backup Schedule Disable
# Disable cron-based scheduled backups
#
add_action :backup_schedule_disable

actions @action_list
