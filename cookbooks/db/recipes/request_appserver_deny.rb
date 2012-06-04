#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Request all database close ports to this application server"
db node[:db][:data_dir] do
  machine_tag "database:active=true"
  enable false
  ip_addr node[:cloud][:private_ips][0]
  action :firewall_update_request
end

rightscale_marker :end
