#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Required attributes
default[:puppet][:client][:puppet_master_address] = ""

# Optional attributes
default[:puppet][:client][:version] = "2.7.13-1"
default[:puppet][:client][:puppet_master_port] = "8140"
default[:puppet][:client][:node_name] = node[:fqdn]
default[:puppet][:client][:environment] = ""

# Platform specific attributes
case platform
when "redhat", "centos"
  set[:puppet][:client][:packages] = ["puppet"]
when "ubuntu"
  set[:puppet][:client][:packages] = ["puppet-common", "puppet"]
else
  set[:puppet][:client][:packages] = []
end
