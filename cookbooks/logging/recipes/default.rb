#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Determine if syslog-ng or rsyslog is installed.
# Note: The desired package must be installed either as part of the base image or
# via a recipe prior to calling this recipe
`which syslog-ng`
syslog_ng_installed = $?.exitstatus == 0 ? true : false
`which rsyslogd`
rsyslog_installed = $?.exitstatus == 0 ?  true : false
raise "ERROR: Both or neither syslog-ng or rsyslog is installed!" unless syslog_ng_installed ^ rsyslog_installed

log_provider = rsyslog_installed ? "logging_rsyslog" : "logging_syslog_ng"
remote_server = node[:logging][:remote_server]
log_str = remote_server == "" ? "DISABLED" : remote_server
log "  Logging provider: #{log_provider}"
log "  Remote log server: #{log_str}"

logging "default" do
  persist true
  provider log_provider
  remote_server remote_server
  action :configure
end

rightscale_marker :end
