#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version="7"
node[:app_tomcat][:version] = version
log "  Setting Tomcat version to #{version}"

#Defining app user and group attributes
case node[:platform]
when "centos", "redhat"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
  node[:app_tomcat][:configuration_file_path] = "/etc/default/tomcat#{version}"
  node[:app_tomcat][:jkworkersfile] = "/etc/tomcat#{version}/workers.properties"
when "ubuntu"
  node[:app][:user] = "tomcat7"
  node[:app][:group] = "tomcat7"
  node[:app_tomcat][:configuration_file_path] = "/etc/tomcat#{version}/tomcat#{version}.conf"
  node[:app_tomcat][:jkworkersfile]="/etc/libapache2-mod-jk/workers.properties"
else
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting "
end

# Preparing list of database adapter packages depending on platform and database adapter
case node[:app][:db_adapter]
when "mysql"
  node[:app][:packages] = value_for_platform(
    ["centos", "redhat"] => {
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
    ["centos", "redhat"] => {
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
        
rightscale_marker :end
