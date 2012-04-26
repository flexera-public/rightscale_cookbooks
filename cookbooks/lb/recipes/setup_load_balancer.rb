# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

VHOST_NAMES = node[:lb][:vhost_names]

log "  Install load balancer" 

# In the 'install' action, the name is not used,
# but the provider from default recipe is needed.
# Any vhost name set with provider can be used.
# Using first one in list to make it simple.
lb vhosts(VHOST_NAMES).first do
  action :install
end

vhosts(VHOST_NAMES).each do | vhost_name |
  lb vhost_name do
    action :add_vhost
  end
end

rs_utils_marker :end
