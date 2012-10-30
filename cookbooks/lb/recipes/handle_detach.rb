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

# Calls the "detach" action for all pools.
log "Remote recipe executed by do_detach_request"

# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:remote_recipe][:pools]).each do |pool_name|
  # See cookbooks/lb_<provider>/providers/default.rb for the "detach" action.
  lb pool_name do
    backend_id node[:remote_recipe][:backend_id]
    action :detach
  end
end

rightscale_marker :end

