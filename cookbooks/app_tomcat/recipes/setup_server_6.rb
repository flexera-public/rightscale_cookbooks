#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version = "6"
log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_tomcat"
node[:app][:version] = version
log "  Setting tomcat version to #{version}"

# Defining appplication user and group attributes depending on platform
case node[:platform]
when "ubuntu"
  node[:app][:user] = "tomcat6"
  node[:app][:group] = "tomcat6"
  node[:app_tomcat][:configuration_file_path] = "/etc/default/tomcat#{version}"
  if node[:platform_version] == "10.04"
    node[:app_tomcat][:jkworkersfile] =
      "/etc/tomcat#{version}/workers.properties"
  else
    node[:app_tomcat][:jkworkersfile] =
      "/etc/libapache2-mod-jk/workers.properties"
  end
when "centos", "redhat"
  node[:app][:user] = "tomcat"
  node[:app][:group] = "tomcat"
  node[:app_tomcat][:configuration_file_path] =
    "/etc/tomcat#{version}/tomcat#{version}.conf"
  node[:app_tomcat][:jkworkersfile] = "/etc/tomcat#{version}/workers.properties"
else
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting "
end

# Preparing list of packages depending on platform
node[:app][:packages] = value_for_platform(
  ["centos", "redhat"] => {
    "default" => [
      "java-1.6.0-openjdk",
      "ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native"
    ]
  },
  "ubuntu" => {
    "default" => [
      "openjdk-6-jre-headless",
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

if node[:app][:packages].empty?
  raise "Unrecognized distro #{node[:platform]} for tomcat#{version}, exiting"
end

rightscale_marker :end
