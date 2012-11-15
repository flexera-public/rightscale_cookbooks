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

# Calls the "detach_request" action for all the pools.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:lb][:pools]).each do |pool_name|
  log "  Remove the load balancing tags, so we will not be re-attached. - #{pool_name}"
  # See cookbooks/lb/definitions/lb_tag.rb for the "lb_tag" definition.
  lb_tag pool_name do
    action :remove
  end

  log "  Sending remote detach request..."
  # See cookbooks/lb_<provider>/provider/default.rb for the "detach_request" action.
  lb pool_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    backend_port node[:app][:port].to_i
    service_region node[:lb][:service][:region]
    service_lb_name node[:lb][:service][:lb_name]
    service_account_id node[:lb][:service][:account_id]
    service_account_secret node[:lb][:service][:account_secret]
    action :detach_request
  end
end

rightscale_marker :end
