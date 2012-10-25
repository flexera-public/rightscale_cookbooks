#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

DATA_DIR = node[:db][:data_dir]

# See cookbooks/db/recipes/do_secondary_restore.rb
include_recipe "db::do_secondary_restore"

# See cookbooks/db/definitions/db_register_master.rb for the implementation of
# db_register_master definition.
db_register_master

db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for setup_monitoring action.
  action :setup_monitoring
end

# See cookbooks/db/recipes/setup_replication_privileges.rb
include_recipe "db::setup_replication_privileges"

# Setting admin and application user privileges
# See cookbooks/db/definitions/db_set_privileges.rb for the implementation of
# db_set_privileges definition.
db_set_privileges [
  {:role => "administrator", :username => node[:db][:admin][:user], :password => node[:db][:admin][:password]},
  {:role => "user", :username => node[:db][:application][:user], :password => node[:db][:application][:password]}
]

# Perform first backup so that slaves can init from this master
# See cookbooks/db/definitions/db_request_backup.rb for the implementation of
# db_request_backup definition.
db_request_backup "do backup"

# See cookbooks/db/recipes/do_primary_backup_schedule_enable.rb
include_recipe "db::do_primary_backup_schedule_enable"

rightscale_marker :end
