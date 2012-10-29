#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Loads helper from cookbooks/lb_<provider>/providers/libraries/helper.rb
class Chef::Recipe
  include RightScale::App::Helper
end

# Adds the collectd exec plugin to the set of collectd plugins if it isn't already there.
rightscale_enable_collectd_plugin 'exec'

# Rebuilds the collectd configuration file if necessary.
# See cookbooks/rightscale/recipes/setup_monitoring.rb for
# the "rightscale::setup_monitoring" recipe
include_recipe "rightscale::setup_monitoring"

# Creates the collectd library plugins directory if necessary.
directory File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

# See cookbooks/lb_<provider>/providers/default.rb for the "setup_monitoring" action.
log "  Setup Monitoring"
lb pool_names(node[:lb][:pools]).first do
  action :setup_monitoring
end

rightscale_marker :end
