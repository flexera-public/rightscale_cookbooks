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
  error_message "Database already restored.  To over write existing database run do_force_reset before this recipe"
end

log "  Running pre-restore checks..."
db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for the "pre_restore_check" action
  action :pre_restore_check
end

log "  Stopping database..."
db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for the "stop" action.
  action :stop
end

# See cookbooks/block_device/libraries/block_device.rb for
# "set_restore_params" and "get_device_or_default" methods.
lineage, timestamp_override = set_override_attrs(
  node[:db][:backup][:lineage],
  node[:db][:backup][:lineage_override],
  node[:db][:backup][:timestamp_override]
)

secondary_storage_cloud = get_device_or_default(node, :device1, :backup, :secondary, :cloud)
if secondary_storage_cloud =~ /aws/i
  secondary_storage_cloud = "s3"
elsif secondary_storage_cloud =~ /rackspace/i
  secondary_storage_cloud = "cloudfiles"
end

log "  Performing Secondary Restore from #{node[:db][:backup][:secondary_location]}..."
# Requires block_device DATA_DIR to be previously instantiated.
# Make sure block_device::default recipe has been run.
# See cookbooks/block_device/providers/default.rb for the "secondary_restore" action.
block_device NICKNAME do
  lineage lineage
  timestamp_override timestamp_override

  volume_size get_device_or_default(node, :device1, :volume_size)

  secondary_cloud secondary_storage_cloud
  secondary_endpoint get_device_or_default(node, :device1, :backup, :secondary, :endpoint) || ""
  secondary_container get_device_or_default(node, :device1, :backup, :secondary, :container)
  secondary_user get_device_or_default(node, :device1, :backup, :secondary, :cred, :user)
  secondary_secret get_device_or_default(node, :device1, :backup, :secondary, :cred, :secret)

  action :secondary_restore
end

log "  Setting state of database to be 'initialized'..."
# See cookbooks/db/definitions/db_init_status.rb for the "db_init_status" definition.
db_init_status :set

log "  Running post-restore cleanup..."
# See cookbooks/db_<provider>/providers/default.rb for the "post_restore_cleanup" action.
db DATA_DIR do
  action :post_restore_cleanup
end

log "  Starting database..."
# See cookbooks/db_<provider>/providers/default.rb for the "start" and "status" actions.
db DATA_DIR do
  action [:start, :status]
end

# Restoring admin and application user privileges
# See cookbooks/db/definitions/db_set_privileges.rb for the "db_set_privileges" definition.
db_set_privileges [
  {:role => "administrator", :username => node[:db][:admin][:user], :password => node[:db][:admin][:password]},
  {:role => "user", :username => node[:db][:application][:user], :password => node[:db][:application][:password]}
]

rightscale_marker :end
