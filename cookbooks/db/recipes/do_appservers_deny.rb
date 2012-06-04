#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Closing database port(s) to all application servers"
db node[:db][:data_dir] do
  machine_tag "appserver:active=true"
  enable false
  action :firewall_update
end

rightscale_marker :end
