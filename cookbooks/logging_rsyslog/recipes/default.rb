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

raise "ERROR: Rsyslog is not installed!" unless system("which rsyslogd")
raise "ERROR: Rsyslog version doesn't support RELP" if node[:logging][:protocol] == "relp" and node[:platform_version] =~ /^5\..+/
raise "ERROR: RELP+STunnel isn't implemented for this OS" unless node[:logging][:protocol] == "relp+stunnel" and node[:platform_version] =~ /^10\..+/
raise "ERROR: TLS support for this OS isn't implemented: use RELP+STunnel" unless node[:logging][:protocol] == "tcp+tls" and node[:platform_version] =~ /^5\..+/

node[:logging][:provider] = "logging_rsyslog"

rightscale_marker :end
