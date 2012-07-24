#
# Cookbook Name:: logging_rsyslog
# Recipe:: default
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.
#
rightscale_marker :begin

# This is needed for the server setup - not used for client.  The client provider
# is set via the provider input.
# There will be separate templates for syslog-ng/rsyslog server sides.  The choice
# will be made by the inclusion of the logging*::default recipe
log "  Setting provider specific settings for rsyslog server."

`rpm -qa | grep rsyslog`
rsyslog_installed = $?.exitstatus == 0 ?  true : false
raise "ERROR: Rsyslog is not installed!" unless rsyslog_installed

node[:logging][:provider] = "logging_rsyslog"

case node[:platform]
when "centos", "redhat"
  case node[:platform_version]
  when /^5\..+/
    node[:logging][:config_dir] = "/etc/rsyslog.conf"
  else
    raise "Version #{node[:platform_version]} not supported."
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

rightscale_marker :end
