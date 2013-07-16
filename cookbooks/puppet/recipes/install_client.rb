#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Declares touchfile, which will be used to avoid the code execution on reboot.
t_file = "/var/lib/puppet/ssl/certs/#{node[:puppet][:client][:node_name]}.pem"

# Sets the version suffix to comply with platform.
os_suffix = node[:platform] == "ubuntu" ? "puppetlabs1" : ".el6"

# Platform specific attributes
node[:puppet][:client][:packages] = value_for_platform(
  ["centos", "redhat"] => {"default" => ["puppet"]},
  ["ubuntu"] => {"default" => ["puppet-common", "puppet"]},
  "default" => []
  )

# Update packages based on OS.  Error out if OS not supported.
if node[:puppet][:client][:packages].empty?
  raise "Unsupported platform - #{node[:platform]}"
end

# Installs the Puppet Client specific to the user provided version.
node[:puppet][:client][:packages].each do |pkg|
  package pkg do
    version "#{node[:puppet][:client][:version]}#{os_suffix}"
  end
end

# Configures to enable init process to start puppet client service on Ubuntu.
cookbook_file "/etc/default/puppet" do
  source "puppet_enable_init"
  cookbook "puppet"
  only_if { node[:platform] == "ubuntu" }
end

# Initializing supported commands for puppet client service for further usage.
service "puppet" do
  persist true
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Creates the Puppet Client configuration file.
template "/etc/puppet/puppet.conf" do
  source "puppet_client.conf.erb"
  mode 0644
  backup false
  cookbook "puppet"
  variables(
    :master_address => node[:puppet][:client][:puppet_master_address],
    :node_name => node[:puppet][:client][:node_name],
    :master_port => node[:puppet][:client][:puppet_master_port],
    :environment => node[:puppet][:client][:environment]
  )
end

# Performs certificate registration on the Puppet Master. This execute resource
# interprets exit code 0, 1 and 2 as success.
# An exit code of 1 from 'puppet agent --test' command results in not creating
# the 't_file', which will trigger logging a warning in the
# ruby_block[registration-status], called by the notifies attribute.
execute "run puppet-client" do
  command "puppet agent --test"
  returns [0, 1, 2]
  creates t_file
  notifies :create, "ruby_block[registration-status]"
end

ruby_block "registration-status" do
  block do
    if File.exists?(t_file)
      Chef::Log.info("  Puppet Client certificate registration successful.")
    else
      Chef::Log.warn("  Puppet Client certificate registration failed. Your" +
        " Puppet Master may not be Operational or it is not auto-signing" +
        " client certificates. Ensure client certificate is signed on the" +
        " Puppet Master and run recipe puppet::reload_agent")
    end
  end
  action :nothing
end

# Enables and starts puppet client service on successful client registration.
service "puppet" do
  action [:enable, :start]
  only_if { ::File.exists?(t_file) }
end
