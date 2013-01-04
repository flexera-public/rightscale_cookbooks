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

DATA_DIR = node[:db][:data_dir]
# See cookbooks/block_device/libraries/default.rb for the "get_device_or_default" method.
NICKNAME = get_device_or_default(node, :device1, :nickname)

log "  Verify if database state is 'uninitialized'..."
# See cookbooks/db/definitions/db_init_status.rb for the "db_init_status" definition.
db_init_status :check do
  expected_state :uninitialized
  error_message "Database already initialized.  To over write existing database run do_force_reset before this recipe"
end

log "  Stopping database..."
# See cookbooks/db_<provider>/providers/default.rb for the "stop" action.
db DATA_DIR do
  action :stop
end

log "  Creating block device..."

# See cookbooks/block_device/providers/default.rb for the "create" action.
block_device NICKNAME do
  lineage node[:db][:backup][:lineage]
  action :create
end

log "  Creating directory in the block device..."
directory DATA_DIR do
  mode "0755"
  action :create
end

log "  Moving database to block device and starting database..."

# See cookbooks/db_<provider>/providers/default.rb for the "move-data_dir" and "start" actions.
db DATA_DIR do
  action [:move_data_dir, :start]
end

log "  Setting state of database to be 'initialized'..."
db_init_status :set

log "  Registering as master..."
# See cookbooks/db/definitions/db_register_master.rb for the "db_register_master" definition.
db_register_master

log "  Setting up monitoring for master..."
# See cookbooks/db_<provider>/providers/default.rb for the "setup_monitoring" action.
db DATA_DIR do
  action :setup_monitoring
end

log "  Adding replication privileges for this master database..."
# See cookbooks/db/recipes/setup_replication_privileges.rb for the "db::setup_replication_privileges" recipe.
include_recipe "db::setup_replication_privileges"

log "  Perform a backup so slaves can init from this master..."
# See cookbooks/db/definitions/db_request_backup.rb for the "db_request_backup" definition.
db_request_backup "do backup"

log "  Setting up cron to do scheduled backups..."
# See cookbooks/db/recipes/do_primary_backup_schedule_enable.rb for the "db::do_primary_backup_schedule_enable" recipe.
include_recipe "db::do_primary_backup_schedule_enable"

rightscale_marker :end
