#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if node[:rightscale][:security_updates] == "enable"
  log "  Security updates enabled. Setting up monitoring."
  platform = node[:platform]
  case platform
  when "ubuntu"
    log "  Install Ubuntu security monitoring package dependencies and plugin"
    package "update-notifier-common"
    # Install custom collectd plugin
    #
    directory "#{node[:rightscale][:collectd_lib]}/plugins" do
      owner "root"
      group "root"
      recursive true
      action :create
    end

    cookbook_file "#{node[:rightscale][:collectd_lib]}/plugins/update_monitor" do
      source "update_monitor_collectd_plugin.rb"
      mode 0755
    end

    rightscale_enable_collectd_plugin "exec"

    template "#{node[:rightscale][:collectd_plugin_dir]}/update_monitor.conf" do
      source "update_monitor.conf.erb"
      variables(
        :collectd_lib => node[:rightscale][:collectd_lib],
        :server_uuid => node[:rightscale][:instalce_uuid]
      )
      mode 0644
    end

  when "centos", "redhat"
    log "  Install CentOS security monitoring package dependencies and plugin"
    log "  ERROR/TBD/XXXX - centos implementation not complete"
  else
    log "  Usupportted OS: #{platform}"
  end
else
  log "  Security updates disabled.  Skipping monitoring setup!"
end
