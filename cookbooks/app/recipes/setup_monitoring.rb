#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will call "setup_monitoring" action of "app" LightWeight resource
#  For more info please see "setup_monitoring" action definition in connected LightWeight provider (ex. app_tomcat/providers/default.rb)

rightscale_marker :begin

log "  Configuring monitoring for app server"
app "default" do
  action :setup_monitoring
end

rightscale_marker :end
