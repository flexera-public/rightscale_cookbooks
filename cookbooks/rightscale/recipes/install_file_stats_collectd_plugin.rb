#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Load the exec plugin in the main config file
# See cookbooks/rightscale/definitions/rightscale_enable_collectd_plugin.rb for the "rightscale_enable_collectd_plugin" definition.
rightscale_enable_collectd_plugin "exec"

# See cookbooks/rightscale/recipes/setup_monitoring.rb for the "rightscale::setup_monitoring" recipe.
include_recipe "rightscale::setup_monitoring"

require 'fileutils'

log "  Installing file_stats collectd plugin.."

template(::File.join(node[:rightscale][:collectd_plugin_dir], "file-stats.conf")) do
  backup false
  source "file-stats.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

directory ::File.join(node[:rightscale][:collectd_lib], "plugins") do
  action :create
  recursive true
end

cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", 'file-stats.rb')) do
  source "file-stats.rb"
  mode "0755"
  notifies :restart, resources(:service => "collectd")
end

# Used in db_mysql::do_backup in rightscale_cookbooks for backups
file node[:rightscale][:db_backup_file] do
  action :touch
  owner "nobody"
  group value_for_platform(
    ["centos", "redhat"] => {
      "default" => "nobody"
    },
    "default" => "nogroup"
  )
end

# Adds custom gauges to collectd 'types.db'.
cookbook_file "#{node[:rightscale][:collectd_plugin_dir]}/rs.types.db" do
  source "rs.types.db"
  backup false
end

# Adds configuration to use the custom gauges.
template "#{node[:rightscale][:collectd_plugin_dir]}/rs.types.db.conf" do
  source "rs.types.db.conf.erb"
  variables(
    :collectd_plugin_dir => node[:rightscale][:collectd_plugin_dir]
  )
  backup false
  notifies :restart, resources(:service => "collectd")
end

log "Installed collectd file_stats plugin."
