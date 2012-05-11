# 
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

require 'uri'

actions :create, :snapshot, :primary_backup, :primary_restore, :secondary_backup, :secondary_restore, :reset, :backup_schedule_enable, :backup_schedule_disable, :backup_lock_take, :backup_lock_give

attribute :nickname, :kind_of => String, :name_attribute => true

attribute :cloud, :required => true
attribute :hypervisor, :kind_of => String
attribute :mount_point, :kind_of => String, :required => true
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false
attribute :is_master, :kind_of => [TrueClass, FalseClass], :default => false


# Backup/Restore options
#
attribute :lineage, :kind_of => String
attribute :timestamp_override, :kind_of => String # Restore only 

 
# Primary Backup
#
# Scheduled options
attribute :cron_backup_minute, :kind_of => String
attribute :cron_backup_hour, :kind_of => String
attribute :cron_backup_recipe, :kind_of => String, :default => "block_device::do_backup"
# Rotation options
attribute :max_snapshots, :kind_of => String
attribute :keep_daily, :kind_of => String
attribute :keep_weekly, :kind_of => String
attribute :keep_monthly, :kind_of => String
attribute :keep_yearly, :kind_of => String
attribute :force, :kind_of => [TrueClass, FalseClass], :default => false # Used by backup_lock_take action
# Volume block devices only
attribute :volume_size, :kind_of => String
attribute :stripe_count, :kind_of => String
attribute :vg_data_percentage, :kind_of => String

# Callbacks for ROS endpoint validation
endpoint_callbacks = {
  "invalid endpoint URL" => Proc.new do |value|
    begin
      URI.parse(value).is_a? URI::HTTP
    rescue URI::InvalidURIError
      false
    end
  end
}

# Remote Object Store only
attribute :primary_cloud, :kind_of => String
attribute :primary_endpoint, :kind_of => String, :callbacks => endpoint_callbacks
attribute :primary_user, :kind_of => String
attribute :primary_secret, :kind_of => String


# Secondary Backup
#
attribute :secondary_cloud, :kind_of => String
attribute :secondary_endpoint, :kind_of => String, :callbacks => endpoint_callbacks
attribute :secondary_container, :kind_of => String
attribute :secondary_user, :kind_of => String
attribute :secondary_secret, :kind_of => String


# Cloud specific options
#
attribute :rackspace_snet, :equal_to => [ true, false ], :default => true


