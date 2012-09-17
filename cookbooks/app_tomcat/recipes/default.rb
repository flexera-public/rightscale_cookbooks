#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_tomcat"

# we do not care about version number here.
# need only the type of database adapter
node[:app][:db_adapter] = node[:db][:provider_type].match(/^db_([a-z]+)/)[1]

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"

# tomcat shares the same doc root with the application destination
node[:app][:root]="#{node[:app][:destination]}"

rightscale_marker :end
