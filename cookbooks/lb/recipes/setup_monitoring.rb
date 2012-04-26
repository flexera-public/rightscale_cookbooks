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

# add the collectd exec plugin to the set of collectd plugins if it isn't already there
rs_utils_enable_collectd_plugin 'exec'

# rebuild the collectd configuration file if necessary
include_recipe "rs_utils::setup_monitoring"

# create the collectd library plugins directory if necessary
directory File.join(node[:rs_utils][:collectd_lib], "plugins") do
  action :create
  recursive true
end

log "  Setup Monitoring"
lb vhosts(node[:lb][:vhost_names]).first do
  action :setup_monitoring
end

rs_utils_marker :end

