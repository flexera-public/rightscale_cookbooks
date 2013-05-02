#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will setup firewall rules on the app server to allow loadbalancers
# to connect to the correct port.

rightscale_marker :begin

# Setup attributes
# If we are using public IP/interface, use the corresponding IP on the LB
if node[:app][:backend_ip_type] == "public"
  rule_ip = node[:app][:lb_public_ip]
else
  rule_ip = node[:app][:lb_private_ip]
end
port = node[:app][:port]

log "  Adding firewall rules for loadbalancer to connect from #{rule_ip}"
# See cookbooks/sys_firewall/providers/default.rb for the "update" action.
sys_firewall port do
  ip_addr rule_ip
  protocol "tcp"
  enable true
  action :update
end

rightscale_marker :end
