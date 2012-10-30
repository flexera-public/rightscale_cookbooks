#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will call "start" action of "app" LightWeight resource
#  For more info please see "start" action definition in connected LightWeight provider (ex. app_php/providers/default.rb)

rightscale_marker :begin

log "  Starting application server now..."
# See cookbooks/app_<providers>/providers/default.rb for the "start" action.
app "default" do
  action :start
end

rightscale_marker :end
