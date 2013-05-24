#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Declares touchfile.
touchfile = ::File.expand_path "/var/lib/puppet/ssl/certs/" +
  "#{node[:puppet][:client][:node_name]}.pem"

# Performs certificate registration on the Puppet Master and returns exit code 0
# or 2 as success.
execute "run puppet-client" do
  command "puppet agent --test"
  returns [0,2]
  creates touchfile
end

# Enables and starts the Puppet client service.
service "puppet" do
  action [ :enable, :start ]
  only_if { ::File.exists?(touchfile) }
end
