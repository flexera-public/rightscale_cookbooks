#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Setup default load balancer resource."

# Sets provider for each pool name.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:lb][:pools]).each do |pool_name|
  lb pool_name do
    provider node[:lb][:service][:provider]
    persist true # Store this resource in node between converges.
    action :nothing
  end
end
