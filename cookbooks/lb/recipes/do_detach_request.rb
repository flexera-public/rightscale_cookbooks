# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

vhosts(node[:lb][:vhost_names]).each do | vhost_name |
  log "  Remove the load balancing tags, so we will not be re-attached. - #{vhost_name}"
  lb_tag vhost_name do
    action :remove
  end

  log "  Sending remote detach request..."
  lb vhost_name do
    backend_ip             node[:cloud][:private_ips][0]
    backend_id             node[:rightscale][:instance_uuid]
    backend_port           8000
    service_region         node[:lb][:service][:region]
    service_lb_name        node[:lb][:service][:lb_name]
    service_account_id     node[:lb][:service][:account_id]
    service_account_secret node[:lb][:service][:account_secret]
    action :detach_request
  end
end

rightscale_marker :end

