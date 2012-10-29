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

# Install haproxy and create main config files.
# Name passed in :install action will be used as default backend.
# Currently, using last item from lb/pools as default backend.
lb pool_names(POOL_NAMES).last do
  action :install
end

pool_names(POOL_NAMES).each do |pool_name|
  lb pool_name do
    action :add_vhost
  end
end

rightscale_marker :end
