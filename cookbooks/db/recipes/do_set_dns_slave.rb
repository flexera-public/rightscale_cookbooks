#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Set Slave DNS Record
# Sets the Slave DNS record to the private ip of the server.
# Raise exception if this server thinks it is a master.

class Chef::Recipe
  include RightScale::Database::Helper
end

# See cookbooks/db/libraries/helper.rb for the "db_state_get" method.
db_state_get node

raise "ERROR: Server is a master" if node[:db][:this_is_master]
log "  WARNING: Slave database is not initialized!" do
  only_if { node[:db][:init_status] == :uninitialized }
  level :warn
end

# See cookbooks/db/libraries/helper.rb
# for the "get_local_replication_interface" method.
bind_ip = get_local_replication_interface
log "   Setting slave #{node[:db][:dns][:slave][:fqdn]} to #{bind_ip}"
# See cookbooks/sys_dns/providers/*.rb for the "set" action.
sys_dns "default" do
  id node[:db][:dns][:slave][:id]
  address bind_ip
  action :set
end

rightscale_marker :end
