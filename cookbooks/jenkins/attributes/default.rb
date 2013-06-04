#
# cookbook name:: jenkins
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

# Attributes for Jenkins master

# To support running the use of this cookbook inside a Vagrant box
if node[:cloud]
  default[:jenkins][:ip] = node[:cloud][:public_ips][0]
else
  default[:jenkins][:ip] = "127.0.0.1"
end
# Jenkins server home
default[:jenkins][:server][:home] = "/var/lib/jenkins"
# Jenkins system user
default[:jenkins][:server][:system_user] = "root"
# Jenkins system group
default[:jenkins][:server][:system_group] = "root"
# Jenkins server port
default[:jenkins][:server][:port] = "8080"
# Jenkins mirror
default[:jenkins][:mirror] = "http://updates.jenkins-ci.org"

# Attributes for Jenkins slave

# Jenkins slave user
default[:jenkins][:slave][:user] = "root"
# Jenkins slave name
default[:jenkins][:slave][:name] = node[:rightscale][:instance_uuid]
# Jenkins slave mode
default[:jenkins][:slave][:mode] = "normal"
# Number of executors for jenkins slave
default[:jenkins][:slave][:executors] = "10"
#
default[:jenkins][:private_key_file] = "#{node[:jenkins][:server][:home]}/" +
  "jenkins_key"
default[:jenkins][:slave][:attach_status] = "unattached"

# Required attributes
#

# Jenkins user name
default[:jenkins][:server][:user_name] = ""
# Jenkins user email
default[:jenkins][:server][:user_email] = ""
# Jenkins user full name
default[:jenkins][:server][:user_full_name] = ""
# Jenkins password
default[:jenkins][:server][:password] = ""

# Optional attributes
#

# Jenkins version to install
default[:jenkins][:server][:version] = ""
# Jenkins plugins to install
default[:jenkins][:server][:plugins] = ""
