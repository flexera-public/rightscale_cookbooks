#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Does a database backup of the filesystem containing the database. Since this
# backup is a snapshot of a filesystem, it will check if the database has
# been 'initialized', else it will fail.
#
# @param backup_type [String] If 'primary' will do a primary backup using node
# attributes specific to the main backup. If 'secondary' will do a secondary
# backup using node attributes for secondary.  Secondary uses 'ROS'.
#
# @raise [RuntimeError] If database is not 'initialized'
#
define :db_do_backup, :backup_type => "primary" do

  class Chef::Recipe
    include RightScale::BlockDeviceHelper
  end

  class Chef::Resource::BlockDevice
    include RightScale::BlockDeviceHelper
  end

  # See cookbooks/block_device/libraries/block_device.rb for the "get_device_or_default" method.
  NICKNAME = get_device_or_default(node, :device1, :nickname)
  DATA_DIR = node[:db][:data_dir]

  do_backup_type = params[:backup_type] == "primary" ? "primary" : "secondary"

  log "  Checking db_init_status making sure db ready for backup"

  # Check if database is able to be backed up (initialized)
  # must be done in ruby block to expand node during converge not compile
  # See cookbooks/db/definitions/db_init_status.rb for the "db_init_status" definition.
  db_init_status :check do
    expected_state :initialized
    error_message "Database not initialized."
  end

  # Verify initialized database
  # Check database state to verify that we have correctly initialized this server.
  # See cookbooks/db/definitions/db_state_assert.rb for the "db_state_assert" definition.
  db_state_assert :either

  log "  Performing pre-backup check..."
  # See cookbooks/db_<provider>/providers/default.rb for the "pre_backup_check" action.
  db DATA_DIR do
    action :pre_backup_check
  end

  log "Timeout is #{node[:db][:init_timeout]}"

  log "  Performing (#{do_backup_type} backup) lock DB and write backup info file..."
  # See cookbooks/db_<provider>/providers/default.rb for the "lock" and "write_backup_info" actions.
  db DATA_DIR do
    timeout node[:db][:init_timeout]
    action [:lock, :write_backup_info]
  end

  log "  Performing (#{do_backup_type} backup) Snapshot with lineage #{node[:db][:backup][:lineage]}.."
  # Requires block_device node[:db][:block_device] to be instantiated
  # previously. Make sure block_device::default recipe has been run.
  # See cookbooks/block_device/providers/default.rb for the "snapshot" action.
  block_device NICKNAME do
    action :snapshot
  end

  log "  Performing (#{do_backup_type}) Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."
  # See cookbooks/block_device/libraries/block_device.rb for the "get_device_or_default" method.
  # See cookbooks/block_device/providers/default.rb for the "primary_backup" and "secondary_backup" actions.
  
  case do_backup_type
  when 'primary'
    block_device NICKNAME do
      # Select the device to backup and set up arguments required for backup.
      lineage node[:db][:backup][:lineage]
      max_snapshots get_device_or_default(node, :device1, :backup, :primary, :keep, :max_snapshots)
      keep_daily get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_daily)
      keep_weekly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_weekly)
      keep_monthly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_monthly)
      keep_yearly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_yearly)
    
      action :primary_backup
    end

    log "  Performing unlock DB..."
    # See cookbooks/db_<provider>/providers/default.rb for the "unlock" action.
    db DATA_DIR do
      action :unlock
    end
  
  when 'secondary'
    log "  Performing unlock DB..."
    # See cookbooks/db_<provider>/providers/default.rb for the "unlock" action.
    db DATA_DIR do
      action :unlock
    end
    
    block_device NICKNAME do
      # Secondary arguments
      secondary_cloud get_device_or_default(node, :device1, :backup, :secondary, :cloud)
      secondary_endpoint get_device_or_default(node, :device1, :backup, :secondary, :endpoint) || ""
      secondary_container get_device_or_default(node, :device1, :backup, :secondary, :container)
      secondary_user get_device_or_default(node, :device1, :backup, :secondary, :cred, :user)
      secondary_secret get_device_or_default(node, :device1, :backup, :secondary, :cred, :secret)

      action :secondary_backup
    end
  end

  log "  Performing post backup cleanup..."
  # See cookbooks/db_<provider>/providers/default.rb for the "post_backup_cleanup" action.
  db DATA_DIR do
    action :post_backup_cleanup
  end
end
