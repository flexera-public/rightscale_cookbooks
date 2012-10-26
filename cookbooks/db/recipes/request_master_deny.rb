#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Verify initialized database
# Check the node state to verify that we have correctly initialized this server.
# See cookbooks/db/definitions/db_state_assert.rb for "db_state_assert" definition.
db_state_assert :slave

# Request firewall closed
db node[:db][:data_dir] do
  machine_tag "rs_dbrepl:master_instance_uuid=#{node[:db][:current_master_uuid]}"
  enable false
  ip_addr node[:cloud][:private_ips][0]
  # See cookbooks/db_<provider>/providers/default.rb for "firewall_update_request" action.
  action :firewall_update_request
end

rightscale_marker :end
