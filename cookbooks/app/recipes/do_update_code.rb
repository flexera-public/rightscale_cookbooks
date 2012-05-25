#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will call "code_update" action of "app" LightWeight resource
#  For more info please see "code_update" action definition in connected LightWeight provider (ex. app_php/providers/default.rb)

rightscale_marker :begin

log "  Updating project code repository"
app "default" do
  destination node[:app][:destination]
  action :code_update
end

rightscale_marker :end
