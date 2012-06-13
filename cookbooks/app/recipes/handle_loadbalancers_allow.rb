#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will setup firewall rules on the app server to allow loadbalancers to connect to the
# correct port.

rightscale_marker :begin

# Setup attributes
rule_ip = node[:app][:lb_ip]
port = node[:app][:port]

log "  Adding firewall rules for loadbalancer to connect"
sys_firewall port do
  ip_addr rule_ip
  protocol "tcp"
  enable "enable"
  action :update
end

rightscale_marker :end
