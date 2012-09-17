#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version="7"
log "  Setting Tomcat version to #{version}"

log "  Setting provider specific settings for tomcat#{version}"
node[:app][:provider] = "app_tomcat"
node[:app_tomcat][:version] = version

#Defining app user and group attributes
case node[:platform]
when "centos", "redhat"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
when "ubuntu"
  node[:app][:user] = "tomcat7"
  node[:app][:group] = "tomcat7" 
else
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting "
end

# we do not care about version number here.
# need only the type of database adapter
node[:app][:db_adapter] = node[:db][:provider_type].match(/^db_([a-z]+)/)[1]

# Preparing list of database adapter packages depending on platform and database adapter
case node[:app][:db_adapter]
when "mysql"
  node[:app][:packages] = value_for_platform(
    "centos" => {
      "default" => [
        "eclipse-ecj",
        "ecj3",
        "tomcat7",
        "tomcat7-admin-webapps",
        "tomcat7-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ]
    },
    "ubuntu" => {
      "default" => [
        "ecj-gcj",
        "tomcat7",
        "tomcat7-admin",
        "tomcat7-common",
        "tomcat7-user",
        "libmysql-java",
        "libtcnative-1"
      ]
    }
  )
when "postgresql"
  node[:app][:packages] = value_for_platform(
    "centos" => {
      "default" => [
        "eclipse-ecj",
        "ecj3",
        "tomcat7",
        "tomcat7-admin-webapps",
        "tomcat7-webapps",
        "tomcat-native"
      ]
    },
    "ubuntu" => {
      "default" => [
        "ecj-gcj",
        "tomcat7",
        "tomcat7-admin",
        "tomcat7-common",
        "tomcat7-user",
        "libtcnative-1"
      ]
    }
  )
else
  raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting"
end

raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting " if node[:app][:packages].empty?
        
# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# tomcat shares the same doc root with the application destination
node[:app][:root] = "#{node[:app][:destination]}"

directory "#{node[:app][:destination]}" do
  recursive true
end

rightscale_marker :end
