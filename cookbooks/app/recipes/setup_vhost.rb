#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will call "setup_vhost" action of "app" LightWeight resource
#  For more info please see "setup_vhost" action definition in connected LightWeight provider (ex. app_tomcat/providers/default.rb)

rightscale_marker :begin

log "  Configuring vhost file for App server"
# See cookbooks/app_<providers>/providers/default.rb for the "setup_vhost" action.
app "default" do
  root node[:app][:root]
  port node[:app][:port].to_i
  action :setup_vhost
end

rightscale_marker :end
