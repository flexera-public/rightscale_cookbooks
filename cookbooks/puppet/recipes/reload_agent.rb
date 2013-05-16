#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Declares touchfile.
touchfile = ::File.expand_path "/var/lib/puppet/ssl/certs/" +
  "#{node[:puppet][:client][:node_name]}.pem"

# Executes the Puppet client.
# See cookbooks/puppet/definitions/puppet_client_run.rb for the
# "puppet_client_run" definition.
puppet_client_run

rightscale_marker :end
