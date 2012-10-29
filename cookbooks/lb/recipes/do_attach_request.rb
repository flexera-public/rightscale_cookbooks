#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Loads helper from cookbooks/app/libraries/helper.rb
class Chef::Recipe
  include RightScale::App::Helper
end

# Calls the "attach_request" action for all pools.
# See cookbooks/lb_<provider>/providers/default.rb for details of this action.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:lb][:pools]).each do |pool_name|
  log "  Adding tag to answer for vhost load balancing - #{pool_name}."
  lb_tag pool_name

  log "  Sending remote attach request..."
  lb pool_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    backend_port node[:app][:port].to_i
    service_region node[:lb][:service][:region]
    service_lb_name node[:lb][:service][:lb_name]
    service_account_id node[:lb][:service][:account_id]
    service_account_secret node[:lb][:service][:account_secret]
    action :attach_request
  end
end

rightscale_marker :end
