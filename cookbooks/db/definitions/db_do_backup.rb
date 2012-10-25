#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Does a snapshot backup of the filesystem containing the database
# Since this backup is a snapshot of a filesystem, it will check if the database has
# been 'initialized', else it will fail.
#
# @param [String] backup_type If 'primary' will do a primary backup using node attributes specific
#   to the main backup.  If 'secondary' will do a secondary backup using node attributes for
#   secondary.  Secondary uses 'ROS'.
#
# @raise [RuntimeError] If database is not 'initialized'
define :db_do_backup, :backup_type => "primary" do

  class Chef::Recipe
    include RightScale::BlockDeviceHelper
  end

  class Chef::Resource::BlockDevice
    include RightScale::BlockDeviceHelper
  end

  # See cookbooks/block_device/libraries/block_device.rb for implementation of
  # "get_device_or_default" method.
  #
  NICKNAME = get_device_or_default(node, :device1, :nickname)
  DATA_DIR = node[:db][:data_dir]

  do_backup_type  = params[:backup_type] == "primary" ? "primary" : "secondary"

  # Check if database is able to be backed up (initialized)
  # must be done in ruby block to expand node during converge not compile
  log "  Checking db_init_status making sure db ready for backup"
  db_init_status :check do
    expected_state :initialized
    error_message "Database not initialized."
  end

  # Verify initialized database
  # Check the node state to verify that we have correctly initialized this server.
  db_state_assert :either

  log "  Performing pre-backup check..."
  db DATA_DIR do
    # See cookbooks/db_<provider>/providers/defaul.rb for implementation of
    # "pre_backup_check" action.
    action :pre_backup_check
  end

  log "Timeout is #{node[:db][:init_timeout]}"

  log "  Performing (#{do_backup_type} backup) lock DB and write backup info file..."
  db DATA_DIR do
    timeout node[:db][:init_timeout]
    # See cookbooks/db_<provider>/providers/defaul.rb for implementation of
    # "lock" and "write_backup_info" actions.
    action [ :lock, :write_backup_info ]
  end

  log "  Performing (#{do_backup_type} backup) Snapshot with lineage #{node[:db][:backup][:lineage]}.."
  # Requires block_device node[:db][:block_device] to be instantiated
  # previously. Make sure block_device::default recipe has been run.
  block_device NICKNAME do
    # See cookbooks/block_device/providers/default.rb for implementation of
    # "snapshot" action.
    action :snapshot
  end

  log "  Performing unlock DB..."
  db DATA_DIR do
    # See cookbooks/db_<provider>/providers/defaul.rb for implementation of
    # "unlock" action.
    action :unlock
  end

  log "  Performing (#{do_backup_type}) Backup of lineage #{node[:db][:backup][:lineage]} and post-backup cleanup..."
  block_device NICKNAME do
    # Select the device to backup and set up arguments required for backup.
    # See cookbooks/block_device/libraries/block_device.rb for implementation of
    # "get_device_or_default" method.
    lineage node[:db][:backup][:lineage]
    max_snapshots get_device_or_default(node, :device1, :backup, :primary, :keep, :max_snapshots)
    keep_daily get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_daily)
    keep_weekly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_weekly)
    keep_monthly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_monthly)
    keep_yearly get_device_or_default(node, :device1, :backup, :primary, :keep, :keep_yearly)

    # Secondary arguments
    secondary_cloud get_device_or_default(node, :device1, :backup, :secondary, :cloud)
    secondary_endpoint get_device_or_default(node, :device1, :backup, :secondary, :endpoint) || ""
    secondary_container get_device_or_default(node, :device1, :backup, :secondary, :container)
    secondary_user get_device_or_default(node, :device1, :backup, :secondary, :cred, :user)
    secondary_secret get_device_or_default(node, :device1, :backup, :secondary, :cred, :secret)

    # See cookbooks/block_device/providers/default.rb for implementation of
    # "primary_backup" and "secondary_backup" actions.
    action do_backup_type == 'primary' ? :primary_backup : :secondary_backup
  end

  log "  Performing post backup cleanup..."
  db DATA_DIR do
    # See cookbooks/db_<provider>/providers/default.rb for implementation of
    # "post_backup_cleanup" action.
    action :post_backup_cleanup
  end
end
