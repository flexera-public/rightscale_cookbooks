#
# cookbook name:: jenkins
#
# copyright rightscale, inc. all rights reserved.  all access and use subject
# to the rightscale terms of service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements such
# as a rightscale master subscription agreement.

# Recommended attributes
#

# Attributes for Jenkins master

# To support running the use of this cookbook inside a vagrant box
if node[:cloud]
  default[:jenkins][:ip] = node[:cloud][:public_ips][0]
else
  default[:jenkins][:ip] = "127.0.0.1"
end
default[:jenkins][:server][:home] = "/var/lib/jenkins"
default[:jenkins][:server][:system_user] = "root"
default[:jenkins][:server][:system_group] = "root"
default[:jenkins][:server][:port] = "8080"
default[:jenkins][:mirror] = "http://updates.jenkins-ci.org"

# Attributes for Jenkins slave

default[:jenkins][:slave][:user] = "root"
default[:jenkins][:slave][:name] = node[:rightscale][:instance_uuid]
default[:jenkins][:slave][:mode] = "normal"
default[:jenkins][:slave][:executors] = "10"
default[:jenkins][:private_key_file] = "#{node[:jenkins][:server][:home]}/jenkins_key"
default[:jenkins][:slave][:attach_status] = "unattached"
