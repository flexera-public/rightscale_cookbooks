#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Load the exec plugin in the main config file
rightscale_enable_collectd_plugin "exec"

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

# Used in db_mysql::do_backup in cookbooks_premium for backups
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

ruby_block "add_collectd_gauges" do
  block do
    types_file = ::File.join(node[:rightscale][:collectd_share], 'types.db')
    typesdb = IO.read(types_file)
    unless typesdb.include?('gague-age') && typesdb.include?('gague-size')
      typesdb += <<-EOS
        ngauge-age          seconds:GAUGE:0:200000000
        gauge-size          bytes:GAUGE:0:200000000
      EOS
      File.open(types_file, "w") { |f| f.write(typesdb) }
    end
  end
end

log "Installed collectd file_stats plugin."

rightscale_marker :end
