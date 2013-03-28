#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Chef client current role/s: #{node[:chef][:client][:current_roles]}"

if node[:chef][:client][:current_roles] != node[:chef][:client][:roles]
  # Updates runlist.json file with new roles.
  # See cookbooks/chef/definitions/setup_runlist.rb for the "setup_runlist"
  # definition.
  setup_runlist
else
  # Runs the Chef client.
  execute "chef-client"
end

rightscale_marker :end
