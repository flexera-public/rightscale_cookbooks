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

POOL_NAMES = node[:lb][:pools]

log "  Install load balancer"

# Installs haproxy and creates main config files.
# Name passed in the "install" action acts as the default backend.
# Currently, it uses the last item from lb/pools as the default backend.
# See cookbooks/lb_<provider>/providers/default.rb for the "install" action.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
lb pool_names(POOL_NAMES).last do
  action :install
end

pool_names(POOL_NAMES).each do |pool_name|
  # See cookbooks/lb_<provider>/providers/default.rb for the "add_vhost" action.
  lb pool_name do
    action :add_vhost
  end
end

rightscale_marker :end
