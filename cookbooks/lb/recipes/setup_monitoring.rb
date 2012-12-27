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

# Adds the collectd exec plugin to the set of collectd plugins if it isn't already there.
# See cookbooks/rightscale/definitions/rightscale_enable_collectd_plugin.rb for the
# "rightscale_enable_collectd_plugin" definition.
rightscale_enable_collectd_plugin 'exec'

# Rebuilds the collectd configuration file if necessary.
# See cookbooks/rightscale/recipes/setup_monitoring.rb for the
# "rightscale::setup_monitoring" recipe
include_recipe "rightscale::setup_monitoring"

# Creates the collectd library plugins directory if necessary.
directory File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

log "  Setup Monitoring"

# See cookbooks/lb_<provider>/providers/default.rb for the "setup_monitoring" action.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
lb pool_names(node[:lb][:pools]).first do
  action :setup_monitoring
end

rightscale_marker :end
