#
# Cookbook Name::jenkins
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

default[:jenkins][:ip] = node[:cloud][:public_ips][0]
default[:jenkins][:server][:home] = "/var/lib/jenkins"
default[:jenkins][:server][:system_user] = "jenkins"
default[:jenkins][:server][:system_group] = "root"
default[:jenkins][:server][:port] = "8080"

default[:jenkins][:slave][:mode] = "normal"
default[:jenkins][:slave][:executors] = "10"
default[:jenkins][:slave][:private_key_file] = "/root/.ssh/api_user_key"

default[:jenkins][:mirror] = "http://updates.jenkins-ci.org"
default[:jenkins][:attach_slave_at_boot] == "false"