#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include RightScale::BlockDeviceHelper

# Will setup new block device
action :create do
  device = init(new_resource)
  create_options = {
    :volume_size => new_resource.volume_size,
    :stripe_count => new_resource.stripe_count,
    :vg_data_percentage => new_resource.vg_data_percentage,
    :force => new_resource.force
  }
  device.create(create_options)
end

# Create snapshot of given device
action :snapshot do
  device = init(new_resource)
  device.snapshot
end

# Acquire the backup lock
action :backup_lock_take do
  device = init(new_resource)
  device.backup_lock_take(new_resource.force)
end

# Create the backup lock
action :backup_lock_give do
  device = init(new_resource)
  device.backup_lock_give
end

# Prepare device for primary backup
action :primary_backup do
  device = init(new_resource)
  backup_options = {
    :description => "RightScale data backup",
    :from_master => new_resource.is_master,

    :max_snapshots => new_resource.max_snapshots,
    :keep_dailies => new_resource.keep_daily,
    :keep_weeklies => new_resource.keep_weekly,
    :keep_monthlies => new_resource.keep_monthly,
    :keep_yearlies => new_resource.keep_yearly,

    # ROS Based backups only
    :storage_key => new_resource.primary_user,
    :storage_secret => new_resource.primary_secret
  }
  device.primary_backup(new_resource.lineage, backup_options)
end

# Prepare device for primary restore
action :primary_restore do
  device = init(new_resource)
  restore_args = {
    :timestamp => new_resource.timestamp_override == "" ? nil : new_resource.timestamp_override,
    :force => new_resource.force,
    :from_master => new_resource.is_master,
    :new_size_gb => new_resource.volume_size,
    :vg_data_percentage => new_resource.vg_data_percentage,
    :stripe_count => new_resource.stripe_count,
    :volume_size => new_resource.volume_size,

    # ROS Based backups only
    :storage_key => new_resource.primary_user,
    :storage_secret => new_resource.primary_secret
  }

  device.primary_restore(new_resource.lineage, restore_args)
end

# Prepare device for secondary backup
action :secondary_backup do
  secondary_checks(new_resource)
  device = init(new_resource)
  device.secondary_backup(new_resource.lineage)
end

# Prepare device for secondary restore
action :secondary_restore do
  secondary_checks(new_resource)
  device = init(new_resource)
  restore_args = {
    :timestamp => new_resource.timestamp_override == "" ? nil : new_resource.timestamp_override,
    :force => new_resource.force,
    :volume_size => new_resource.volume_size,
    :new_size_gb => new_resource.volume_size,
    :stripe_count => new_resource.stripe_count,
    :vg_data_percentage => new_resource.vg_data_percentage
  }

  device.secondary_restore(new_resource.lineage, restore_args)
end

# Unmount and delete the attached block device(s)
action :reset do
  device = init(new_resource)
  device.reset()
end

# Enable cron backups
action :backup_schedule_enable do

    # Verify parameters
    minute = new_resource.cron_backup_minute
    raise "ERROR: missing cron_backup_minute value." unless minute
    hour = new_resource.cron_backup_hour
    raise "ERROR: missing cron_backup_hour value." unless hour

    # Verify backup params used in cron recipe
    lineage = new_resource.lineage
    raise "ERROR: 'Backup Lineage' required for scheduled process" if lineage.empty?

    # Select recipe to schedule
    recipe = new_resource.cron_backup_recipe

    puts "Scheduling #{recipe} to run via cron job: Minute:#{minute} Hour:#{hour}"

    # Attributes for schedule will default to '*' if not provided so only
    # specify the schedule attributes if input is not an empty string.
    cron "RightScale remote_recipe #{recipe}" do
      minute "#{minute}" unless minute.empty?
      hour "#{hour}" unless hour.empty?
      user "root"
      command "rs_run_recipe -n \"#{recipe}\" 2>&1 > /var/log/rightscale_tools_cron_backup.log"
      action :create
    end

end

# Disable cron backups
action :backup_schedule_disable do
  # Select recipe to disable
  recipe = new_resource.cron_backup_recipe
  log "Disable #{recipe} cron job"

  cron "RightScale remote_recipe #{recipe}" do
    user "root"
    action :delete
  end
end

