#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

class Chef::Resource::BlockDevice
  include RightScale::BlockDeviceHelper
end

DATA_DIR = node[:db][:data_dir]
# See cookbooks/block_device/libraries/block_device.rb for the "get_device_or_default" method.
NICKNAME = get_device_or_default(node, :device1, :nickname)

# See cookbooks/db/definitions/db_init_status.rb for the "db_init_status" definition.
db_init_status :check do
  expected_state :uninitialized
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe."
end

log "  Running pre-restore checks..."

# See cookbooks/db_<provider>/providers/default.rb for the "pre_restore_check" action.
db DATA_DIR do
  action :pre_restore_check
end

if node[:db][:backup][:lineage_override].empty?
  backup_lineage = node[:db][:backup][:lineage]
else
  log "** USING LINEAGE OVERRIDE **"
  backup_lineage = node[:db][:backup][:lineage_override]
end

log "======== LINEAGE ========="
log backup_lineage
log "======== LINEAGE ========="

log "  Stopping database..."
# See cookbooks/db_<provider>/providers/default.rb for the "stop" action.
db DATA_DIR do
  action :stop
end

log "  Performing Restore..."
# Requires block_device node[:db][:block_device] to be instantiated
# previously. Make sure block_device::default recipe has been run.
lineage = node[:db][:backup][:lineage]
lineage_override = node[:db][:backup][:lineage_override]
restore_lineage = lineage_override == nil || lineage_override.empty? ? lineage : lineage_override
restore_timestamp_override = node[:db][:backup][:timestamp_override]
log "  Input lineage #{restore_lineage.inspect}"
log "  Input lineage_override #{lineage_override.inspect}"
log "  Using lineage #{restore_lineage.inspect}"
log "  Input timestamp_override #{restore_timestamp_override.inspect}"
restore_timestamp_override ||= ""

# See cookbooks/block_device/providers/default.rb for the "primary_restore" action.
block_device NICKNAME do
  lineage restore_lineage
  timestamp_override restore_timestamp_override
  volume_size get_device_or_default(node, :device1, :volume_size)
  action :primary_restore
end

log "  Running post-restore cleanup..."
# See cookbooks/db_<provider>/providers/default.rb for the "post_restore_cleanup" action.
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Starting database..."
# See cookbooks/db_<provider>/providers/default.rb for the "start" and "status" actions.
db DATA_DIR do
  action [ :start, :status ]
end

# Restoring admin and application user privileges
# See cookbooks/db/definitions/db_set_privileges.rb for the "db_set_privileges" definition.
db_set_privileges [
  {:role => "administrator", :username => node[:db][:admin][:user], :password => node[:db][:admin][:password]},
  {:role => "user", :username => node[:db][:application][:user], :password => node[:db][:application][:password]}
]

rightscale_marker :end
