#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

collectd_plugins = "#{node[:rightscale][:collectd_lib]}/plugins"

# Creates the collectd plugin directory.
directory collectd_plugins do
  recursive true
end

# Creates the collectd plugin for the Puppet Client stats collection.
cookbook_file "#{collectd_plugins}/Puppet-stats.sh" do
  mode 0755
  backup false
  source "collectd_puppet_client_stats.erb"
end

# Initializing Collectd service for further usage.
service "collectd"

# Creates the collectd conf file for the Puppet Client monitoring.
template "#{node[:rightscale][:collectd_plugin_dir]}/puppet-client.conf" do
  mode 0644
  source "collectd_puppet_client.erb"
  backup false
  variables(
    :stats_file => "#{collectd_plugins}/Puppet-stats.sh"
  )
  notifies :restart, resources(:service => "collectd")
end
