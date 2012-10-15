#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

DATA_DIR = node[:db][:data_dir]

include_recipe "db::do_primary_restore"

db_register_master

db DATA_DIR do
  action :setup_monitoring
end

include_recipe "db::setup_replication_privileges"

# Setting admin and application user privileges
cred = [["administrator", [node[:db][:admin][:user], node[:db][:admin][:password]]],\
        ["user", [node[:db][:application][:user], node[:db][:application][:password]]]]

cred.each do |role, role_cred_values|
  log "  Restoring #{role} privileges."
  db node[:db][:data_dir] do
    privilege role
    privilege_username role_cred_values[0]
    privilege_password role_cred_values[1]
    privilege_database "*.*"
    action :set_privileges
  end
end

# Perform first backup so that slaves can init from this master
db_request_backup "do backup"

include_recipe "db::do_primary_backup_schedule_enable"

rightscale_marker :end
