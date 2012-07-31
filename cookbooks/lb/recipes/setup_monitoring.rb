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

# Add the collectd exec plugin to the set of collectd plugins if it isn't already there.
rightscale_enable_collectd_plugin 'exec'

# Rebuild the collectd configuration file if necessary.
include_recipe "rightscale::setup_monitoring"

# Create the collectd library plugins directory if necessary.
directory File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

log "  Setup Monitoring"
lb vhosts(node[:lb][:pool_names]).keys[0] do
  action :setup_monitoring
end

rightscale_marker :end
