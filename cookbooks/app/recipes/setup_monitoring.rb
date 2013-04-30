#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Configuring monitoring for app server"
# See cookbooks/app_<providers>/providers/default.rb for the "setup_monitoring" action.
app "default" do
  action :setup_monitoring
end

rightscale_marker :end
