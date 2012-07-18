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

node[:logging][:provider] = "logging_rsyslog"

sys_firewall "Open logger listening port" do
  port node[:logging][:port].to_i
  protocol node[:logging][:protocol]
  enable true
  action :update
end

# For Centos 5.8
template "/etc/rsyslog.conf" do
  action :create
  source "rsyslog.d.server.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  cookbook 'logging_rsyslog'
  #variables()
end

logging "restart service" do
  action :restart
end

rightscale_marker :end
