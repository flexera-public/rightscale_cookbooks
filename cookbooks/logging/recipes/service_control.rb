#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

case node[:logging][:service_action]
when "start"
  log "  Starting logging server now..."
  logging "default" do
    action :start
  end
when "stop"
  log "  Stopping logging server now..."
  logging "default" do
    action :stop
  end
when "restart"
  log "  Restarting logging server now..."
  logging "default" do
    action :restart
  end
when "reload"
  log "  Reloading logging server now..."
  logging "default" do
    action :reload
  end
end

rightscale_marker :end
