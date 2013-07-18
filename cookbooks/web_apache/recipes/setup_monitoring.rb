#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Add the collectd exec plugin to the set of collectd plugins if it isn't already there.
# See cookbooks/rightscale/definitions/rightscale_enable_collectd_plugin.rb for the "rightscale_enable_collectd_plugin" definition.
rightscale_enable_collectd_plugin 'exec'

# Rebuild the collectd configuration file if necessary.
# Calls the cookbooks/rightscale/recipes/setup_monitoring.rb recipe.
include_recipe "rightscale::setup_monitoring"

# Additional "httpd/apache2" service definition required for "rightscale_monitor_process".
service "#{node[:web_apache][:config_subdir]}" do
  action :nothing
end

if node[:platform] =~ /redhat|centos/

  collectd_version = node[:rightscale][:collectd_packages_version]
  package "collectd-apache" do
    version "#{collectd_version}" unless collectd_version == "latest"
  end

  if node[:web_apache][:mpm] == "prefork"
    # See cookbooks/rightscale/definitions/rightscale_monitor_process.rb for the "rightscale_monitor_process" definition.
    rightscale_monitor_process "httpd"
  else
    rightscale_monitor_process "httpd.worker"
  end

elsif node[:platform] == 'ubuntu'
  rightscale_monitor_process 'apache2'
else
  log "  WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end

# Add Apache configuration for the status URL and restart Apache if necessary.
template File.join(node[:apache][:dir], 'conf.d', 'status.conf') do
  backup false
  source "apache_status.conf.erb"
  notifies :restart, resources(:service => "apache2")
end

# Create the collectd library plugins directory if necessary.
directory ::File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

# Install the apache_ps collectd script into the collectd library plugins directory.
cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", 'apache_ps')) do
  source "apache_ps"
  mode "0755"
  backup false
  cookbook 'web_apache'
end

# Checking node[:apache][:listen_ports]
# it can be a string if single port is defined
# or array if multiple ports are defined.
if node[:apache][:listen_ports].kind_of?(Array)
  port = node[:apache][:listen_ports][0]
else
  port = node[:apache][:listen_ports]
end

# Add a collectd config file for the Apache collectd plugin and restart collectd if necessary.
template File.join(node[:rightscale][:collectd_plugin_dir], 'apache.conf') do
  backup false
  source "apache_collectd_plugin.conf.erb"
  variables :apache_listen_ports => port
  notifies :restart, resources(:service => "collectd")
end

# Add a collectd config file for the apache_ps script with the exec plugin and restart collectd if necessary.
template File.join(node[:rightscale][:collectd_plugin_dir], 'apache_ps.conf') do
  backup false
  source "apache_collectd_exec.erb"
  notifies :restart, resources(:service => "collectd")
  variables(
    :collectd_lib => node[:rightscale][:collectd_lib],
    :instance_uuid => node[:rightscale][:instance_uuid],
    :apache_user => node[:apache][:user]
  )
end

# Update the collectd config file for the processes collectd plugin and restart collectd if necessary.
template File.join(node[:rightscale][:collectd_plugin_dir], 'processes.conf') do
  backup false
  cookbook "rightscale"
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
  variables(
    :process_list_array => node[:rightscale][:process_list_array],
    :process_match_list => node[:rightscale][:process_match_list]
  )
end
