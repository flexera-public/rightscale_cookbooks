#
# Cookbook Name:: app_jboss
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Defining provider, app user, group attributes
log "  Setting provider specific settings for jboss"
node[:app][:provider] = "app_jboss"
node[:app][:user] = "jboss"
node[:app][:group] = "jboss"

# Preparing list of packages depending on platform
case node[:platform]
when "centos", "redhat"
  node[:app][:packages] = ["java-1.6.0-openjdk"]
when "ubuntu"
  node[:app][:packages] = ["openjdk-6-jre-headless"]
else
  raise "Unrecognized distro #{node[:platform]}, exiting"
end

log "  Setting JBoss internal port to #{node[:app_jboss][:internal_port]}"

# Sets required apache modules.
node[:app_jboss][:module_dependencies] = [
  "proxy",
  "proxy_http",
  "deflate",
  "rewrite"
]
