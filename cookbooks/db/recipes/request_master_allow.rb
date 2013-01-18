#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Resource::Db
  include RightScale::Database::Helper
end

# Verify initialized database
# Check the node state to verify that we have correctly initialized this server.
# See cookbooks/db/definitions/db_state_assert.rb for the "db_state_assert" definition.
db_state_assert :slave

# Request firewall opened
# See cookbooks/db/libraries/helper.rb for the "get_local_replication_interface" method.
# See cookbooks/db_<provider>/providers/default.rb for the "firewall_update_request" action.
db node[:db][:data_dir] do
  machine_tag "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
  enable true
  ip_addr get_local_replication_interface
  action :firewall_update_request
end

rightscale_marker :end
