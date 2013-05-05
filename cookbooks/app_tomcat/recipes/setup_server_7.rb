#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"
version = "7"
node[:app][:provider] = "app_tomcat"
node[:app][:version] = version
log "  Setting Tomcat version to #{version}"

# Defining application user and group attributes
case node[:platform]
when "centos", "redhat"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
  node[:app_tomcat][:configuration_file_path] =
    "/etc/tomcat#{version}/tomcat#{version}.conf"
  node[:app_tomcat][:jkworkersfile] = "/etc/tomcat#{version}/workers.properties"
when "ubuntu"
  node[:app][:user] = "tomcat7"
  node[:app][:group] = "tomcat7"
  node[:app_tomcat][:configuration_file_path] = "/etc/default/tomcat#{version}"
  node[:app_tomcat][:jkworkersfile]="/etc/libapache2-mod-jk/workers.properties"
else
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting "
end

# Preparing list of packages depending on platform
node[:app][:packages] = value_for_platform(
  ["centos", "redhat"] => {
    "default" => [
      "java-1.6.0-openjdk",
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
      "openjdk-6-jre-headless",
      "ecj-gcj",
      "tomcat7",
      "tomcat7-admin",
      "tomcat7-common",
      "tomcat7-user",
      "libtcnative-1"
    ]
  }
)

if node[:app][:packages].empty?
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting"
end

rightscale_marker :end
