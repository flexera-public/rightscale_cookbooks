#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Required attributes
default[:puppet][:client][:puppet_server_address] = ""

# Optional attributes
default[:puppet][:client][:puppet_server_port] = "8140"
default[:puppet][:client][:node_name] = node[:fqdn]
default[:puppet][:client][:environment] = ""

# Platform specific attributes
case platform
when "redhat", "centos"
  # Sets the version to comply with Centos/Redhat format.
  node[:puppet][:client][:version] = "#{node[:puppet][:client][:version]}.el6"

  node[:puppet][:client][:packages] = "puppet"
  node[:puppet][:client][:repo_source] = "puppetlabs-release-6-7.noarch.rpm"
when "ubuntu"
  # Sets the version to comply with Ubuntu format.
  node[:puppet][:client][:version] =
    "#{node[:puppet][:client][:version]}puppetlabs1"

  node[:puppet][:client][:packages] = ["puppet-common", "puppet"]
  node[:puppet][:client][:repo_source] = "puppetlabs-release-precise.deb"
else
  raise "Unsupported platform #{platform}"
end
