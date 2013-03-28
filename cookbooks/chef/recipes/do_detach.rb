#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Removes the Chef client configuration directory.
directory node[:chef][:client][:config_dir] do
  action :delete
  recursive true
end

log "  Client configuration is removed, Chef client is detached from the server"

rightscale_marker :end
