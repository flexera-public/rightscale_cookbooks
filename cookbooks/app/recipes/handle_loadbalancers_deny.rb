#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will disable firewall rules on the app server that allowed loadbalancers to connect to the
# correct port.

rightscale_marker :begin

# Setup attributes
rule_ip = node[:app][:lb_ip]
port = node[:app][:port]

log "  Removing firewall rules used to allow loadbalancer to connect"
# See cookbooks/sys_firewall/resources/default.rb for the "sys_firewall" resource.
# See cookbooks/sys_firewall/providers/default.rb for the "update" action.
sys_firewall port do
  ip_addr rule_ip
  protocol "tcp"
  enable false
  action :update
end

rightscale_marker :end
