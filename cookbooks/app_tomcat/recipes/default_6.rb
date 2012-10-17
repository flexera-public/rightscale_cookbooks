#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version = "6"
node[:app_tomcat][:version] = version
log "  Setting tomcat version to #{version}"

# Defining database adapter parameter, app user and group attributes depending on platform
case node[:platform]
when "ubuntu"
  node[:app][:user] = "tomcat6"
  node[:app][:group] = "tomcat6"
  node[:app_tomcat][:configuration_file_path] = "/etc/default/tomcat#{version}"
  if node[:platform_version] == "10.04"
    node[:app_tomcat][:jkworkersfile] = "/etc/tomcat#{version}/workers.properties"
  else
    node[:app_tomcat][:jkworkersfile] = "/etc/libapache2-mod-jk/workers.properties"
  end
when "centos", "redhat"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
  node[:app_tomcat][:configuration_file_path] = "/etc/tomcat#{version}/tomcat#{version}.conf"
  node[:app_tomcat][:jkworkersfile] = "/etc/tomcat#{version}/workers.properties"
else
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting "
end

# Preparing list of database adapter packages depending on platform and database adapter
case node[:app][:db_adapter]
when "mysql"
  node[:app][:packages] = value_for_platform(
    ["centos", "redhat"] => {
      "5.8" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ],  
     "default" => [
        "ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native",
        "mysql-connector-java"
      ]   
    },
    "ubuntu" => {
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
    "default" => []
  )
when "postgres"
  node[:app][:packages] = value_for_platform(
    ["centos", "redhat"] => {
      "5.8" => [
        "eclipse-ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native"
      ],
      "default" => [
        "ecj",
        "tomcat6",
        "tomcat6-admin-webapps",
        "tomcat6-webapps",
        "tomcat-native"
      ]
    },
    "ubuntu" => {
      "default" => [
        "ecj-gcj",
        "tomcat6",
        "tomcat6-admin",
        "tomcat6-common",
        "tomcat6-user",
        "libtcnative-1"
      ]
    },
    "default" => []
  )
else
  raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting"
end

raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting " if node[:app][:packages].empty?

rightscale_marker :end
