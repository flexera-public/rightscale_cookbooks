#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Add the collectd exec plugin to the set of collectd plugins if it isn't already there
rightscale_enable_collectd_plugin 'exec'

# Rebuild the collectd configuration file if necessary
include_recipe "rightscale::setup_monitoring"

# Additional "httpd/apache2" service definition required for "rightscale_monitor_process"
service "#{node[:apache][:config_subdir]}" do
  action :nothing
end

if node[:platform] =~ /redhat|centos/

  package "collectd-apache"

  if node[:web_apache][:mpm] == "prefork"
    rightscale_monitor_process "httpd"
  else
    rightscale_monitor_process "httpd.worker"
  end

elsif node[:platform] == 'ubuntu'
   rightscale_monitor_process 'apache2'
else
  log "  WARNING: attempting to install collectd-apache on unsupported platform #{node[:platform]}, continuing.."
end

# Add Apache configuration for the status URL and restart Apache if necessary
template File.join(node[:apache][:dir], 'conf.d', 'status.conf') do
  backup false
  source "apache_status.conf.erb"
  notifies :restart, resources(:service => "apache2")
end

# Create the collectd library plugins directory if necessary
directory ::File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

# Install the apache_ps collectd script into the collectd library plugins directory
cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", 'apache_ps')) do
  source "apache_ps"
  mode "0755"
  backup false
  cookbook 'web_apache'
end

# Checking node[:apache][:listen_ports]
# it can be a string if single port is defined
# or array if multiple ports are defined
if node[:apache][:listen_ports].kind_of?(Array)
  port = node[:apache][:listen_ports][0]
else
  port = node[:apache][:listen_ports]
end

# Add a collectd config file for the Apache collectd plugin and restart collectd if necessary
template File.join(node[:rightscale][:collectd_plugin_dir], 'apache.conf') do
  backup false
  source "apache_collectd_plugin.conf.erb"
  variables :apache_listen_ports => port
  notifies :restart, resources(:service => "collectd")
end

# Add a collectd config file for the apache_ps script with the exec plugin and restart collectd if necessary
template File.join(node[:rightscale][:collectd_plugin_dir], 'apache_ps.conf') do
  backup false
  source "apache_collectd_exec.erb"
  notifies :restart, resources(:service => "collectd")
end

# Update the collectd config file for the processes collectd plugin and restart collectd if necessary
template File.join(node[:rightscale][:collectd_plugin_dir], 'processes.conf') do
  backup false
  cookbook "rightscale"
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

rightscale_marker :end
