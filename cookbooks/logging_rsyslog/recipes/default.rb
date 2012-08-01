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

case node[:platform_version]
when "ubuntu"
  rsyslog_installed = %x(apt-cache policy rsyslog).include?("Installed: (none)") ? false : true
when "centos", "redhat"
  rsyslog_installed = %x(yum list rsyslog).include?("Installed Packages") ? true : false
end

raise "ERROR: Rsyslog is not installed!" unless rsyslog_installed
raise "ERROR: Rsyslog version doesn't support RELP" if node[:logging][:protocol] == "relp" and node[:platform_version] =~ /^5\..+/

node[:logging][:provider] = "logging_rsyslog"
node[:logging][:cert_dir] = "/etc/tls/"

rightscale_marker :end
