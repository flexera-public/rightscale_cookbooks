#
# Cookbook Name::jenkins
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

# Attributes for Jenkins master

if node[:cloud]
  default[:jenkins][:ip] = node[:cloud][:public_ips][0]
else
  # To support running the use of this cookbook inside a vagrant box
  default[:jenkins][:ip] = "127.0.0.1"
end
default[:jenkins][:server][:home] = "/var/lib/jenkins"
default[:jenkins][:server][:system_user] = "root"
default[:jenkins][:server][:system_group] = "root"
default[:jenkins][:server][:port] = "8080"
default[:jenkins][:mirror] = "http://updates.jenkins-ci.org"

# Attributes for Jenkins slave

default[:jenkins][:slave][:user] = "root"
default[:jenkins][:slave][:mode] = "normal"
default[:jenkins][:slave][:executors] = "10"
default[:jenkins][:private_key_file] = "#{node[:jenkins][:server][:home]}/jenkins_key"
default[:jenkins][:slave][:attach_status] = "unattached"
