#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Load the mysql plugin in the main config file
rightscale_enable_collectd_plugin "mysql"

include_recipe "rightscale::setup_monitoring"

log "Installing MySQL collectd plugin"

package "collectd-mysql" do
  only_if { node[:platform] =~ /redhat|centos/ }
end

cookbook_file "#{node[:rightscale][:collectd_plugin_dir]}/mysql.conf" do
  backup false
  source "collectd.mysql.conf"
  notifies :restart, resources(:service => "collectd")
end

# When using the dot notation the following error is thrown:
#
# You tried to set a nested key, where the parent is not a hash-like object: rightscale/process_list/process_list
#
# The only related issue I could find was for Chef 0.9.8 - http://tickets.opscode.com/browse/CHEF-1680
rightscale_monitor_process "mysqld"
template File.join(node[:rightscale][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

rightscale_marker :end
