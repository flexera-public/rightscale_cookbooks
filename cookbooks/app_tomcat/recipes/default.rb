#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_tomcat"

# Defining app user and group attributes
case node[:platform]
when "ubuntu", "debian"
  node[:app][:user] = "tomcat6"
  node[:app][:group] = "tomcat6"
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Preparing list of database adapter packages depending on platform and database adapter
case node[:app][:db_adapter]
when "mysql"
  node[:app][:packages] = value_for_platform(
    "centos" => {
      "6.2" => [
        "ecj", 
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ],  
      "default" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ]   
    }, 
    [ "ubuntu", "debian" ] => {
      "default"  => [
        "ecj-gcj",
        "tomcat6",
        "tomcat6-admin",
        "tomcat6-common",
        "tomcat6-user",
        "libmysql-java",
        "libtcnative-1"
      ]   
    }, 
    [ "fedora", "suse", "redhat", "redhatenterpriseserver" ] => {
      "default" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ]
    },
    "default" => []
  )
when "postgresql"
  node[:app][:packages] = value_for_platform(
    "centos" => {
      "6.2" => [
        "ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native"
      ],
      "default" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native"
      ]
    },
    [ "ubuntu", "debian" ] => {
      "default" => [
        "ecj-gcj",
        "tomcat6",
        "tomcat6-admin",
        "tomcat6-common",
        "tomcat6-user",
        "libtcnative-1"
      ]
    },
    [ "fedora", "suse", "redhat", "redhatenterpriseserver" ] => {
      "default" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native"
      ]
    },
    "default" => []
  )
else
  raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting"
end

raise "Unrecognized distro #{node[:platform]}, exiting " if node[:app][:packages].empty?

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"

# tomcat shares the same doc root with the application destination
node[:app][:root]="#{node[:app][:destination]}"

rightscale_marker :end
