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

POOL_NAMES = node[:lb][:pools]

log "  Install load balancer"

# Installs haproxy and creates main config files.
# Name passed in the "install" action acts as the default backend.
# Currently, it uses the last item from lb/pools as the default backend.
# See cookbooks/lb_<provider>/providers/default.rb for more information
# about this action.
lb pool_names(POOL_NAMES).last do
  action :install
end

# See cookbooks/lb_<provider>/providers/default.rb for the "add_vhost" action.
pool_names(POOL_NAMES).each do |pool_name|
  lb pool_name do
    action :add_vhost
  end
end

rightscale_marker :end
