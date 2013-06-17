#
# Cookbook Name:: jenkins
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# The java package to install based on platform family
node[:jenkins][:java_package] = value_for_platform_family(
  "debian" => "openjdk-6-jre",
  "default" => "java-1.6.0-openjdk"
)

# The jenkins system configuration file location based on platform family
node[:jenkins][:system_config_file] = value_for_platform_family(
  "debian" => "/etc/default/jenkins",
  "default" => "/etc/sysconfig/jenkins"
)
