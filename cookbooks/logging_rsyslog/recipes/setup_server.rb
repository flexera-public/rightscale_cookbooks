#
# Cookbook Name:: logging_rsyslog
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# This is needed for the server setup - not used for client.  The client provider
# is set via the provider input.
# There will be separate templates for syslog-ng/rsyslog server sides.  The choice
# will be made by the inclusion of the logging*::default recipe
log "  Setting provider specific settings for rsyslog server."

raise "ERROR: Rsyslog is not installed!" unless system("which rsyslogd > /dev/null 2>&1")

node[:logging][:provider] = "logging_rsyslog"

rightscale_marker :end
