#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_tomcat"
node[:app][:database_name] = node[:app_tomcat][:db_name]

# Preparing list of database adapter packages depending on platform and database adapter
case node[:app_tomcat][:db_adapter]
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
    })
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
    })
else
  raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting"
end

# Setting app LWRP attribute
node[:app][:root] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# tomcat shares the same doc root with the application destination
node[:app][:destination]="#{node[:app][:root]}"

directory "#{node[:app][:destination]}" do
  recursive true
end

rightscale_marker :end
