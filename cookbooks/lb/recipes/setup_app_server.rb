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

log "  Set provider for load balancing."

vhosts(node[:lb][:vhost_names]).each do | vhost_name |
  lb vhost_name do
    provider node[:lb][:service][:provider]
    persist true  # store this resource in node between converges
    action :nothing
  end
end

rightscale_marker :end
