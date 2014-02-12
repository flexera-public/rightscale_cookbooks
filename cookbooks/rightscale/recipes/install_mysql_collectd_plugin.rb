#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Load the mysql plugin in the main config file
rightscale_enable_collectd_plugin "mysql"

# See cookbooks/rightscale/recipes/setup_monitoring.rb for the "rightscale::setup_monitoring" recipe.
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

# See cookbooks/rightscale/definitions/rightscale_monitor_process.rb for the "rightscale_monitor_process" definition.
rightscale_monitor_process "mysqld"
template File.join(node[:rightscale][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
  variables(
    :process_list_array => node[:rightscale][:process_list_array],
    :process_match_list => node[:rightscale][:process_match_list]
  )
end
