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

POOL_NAMES = node[:lb][:pool_names]

log "  Install load balancer"

# In the 'install' action, the name is not used, but the provider from default recipe is needed.
# Any vhost name set with provider can be used. Using first one in list to make it simple.
lb vhosts(POOL_NAMES).keys[0] do
  action :install
end

vhosts(POOL_NAMES).each_key do |pool_name|
  lb pool_name do
    action :add_vhost
  end
end

rightscale_marker :end
