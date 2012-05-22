#
# Cookbook Name::app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will call "setup_db_connection" action of "app" LightWeight resource
#  For more info please see "setup_db_connection" action definition in connected LightWeight provider (ex. app_php/providers/default.rb)

rightscale_marker :begin

log "  Creating database config for application"
app "default" do
  database_name        node[:app][:database_name]
  database_user        node[:app][:database_user]
  database_password    node[:app][:database_password]
  database_sever_fqdn  node[:app][:database_sever_fqdn]
  action :setup_db_connection
end

rightscale_marker :end
