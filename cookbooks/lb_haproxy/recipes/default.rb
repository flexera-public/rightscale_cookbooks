# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Override load balancer to use HAProxy."
node[:lb][:service][:provider] = "lb_haproxy"

vhosts(node[:lb][:vhost_names]).each do | vhost_name |
  log "  Setup default load balancer resource for vhost '#{vhost_name}'."
  lb vhost_name do
    provider "lb_haproxy"
    persist true  # store this resource in node between converges
    action :nothing
  end
end

rightscale_marker :end
