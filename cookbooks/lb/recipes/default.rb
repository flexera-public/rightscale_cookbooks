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

log "  Setup default load balancer resource."

# Set provider for each vhost.
vhosts(node[:lb][:vhost_names]).each do | vhost_name |
  lb vhost_name do
    provider node[:lb][:service][:provider]
    persist true # Store this resource in node between converges.
    action :nothing
  end
end

gem_package "right_aws" do
  gem_binary "/opt/rightscale/sandbox/bin/gem"
end

# Reload newly install gem.
Gem.clear_paths

rightscale_marker :end
