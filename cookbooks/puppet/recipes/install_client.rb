#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Declares touchfile, which will be used to avoid the code execution on reboot.
touchfile = ::File.expand_path "/var/lib/puppet/ssl/certs/" +
  "#{node[:puppet][:client][:node_name]}.pem"

# Installs the Puppet Open Source package repository.
cookbook_file "/tmp/#{node[:puppet][:client][:repo_source]}" do
  source "#{node[:puppet][:client][:repo_source]}"
  mode "0755"
  cookbook "puppet"
  not_if { ::File.exists?(touchfile) }
end

execute "install puppet repository on Ubuntu" do
  command "sudo dpkg -i /tmp/#{node[:puppet][:client][:repo_source]} && sudo" +
    " apt-get -qq update"
  only_if { node[:platform] == "ubuntu" && !::File.exists?(touchfile) }
end

ruby_block "reload-internal-yum-cache" do
  block do
    Chef::Provider::Package::Yum::YumCache.instance.reload
  end
  action :nothing
end

execute "install puppet repository on CentOS/RHEL" do
  command "rpm -i /tmp/#{node[:puppet][:client][:repo_source]} && yum -q" +
    " makecache"
  notifies :create, "ruby_block[reload-internal-yum-cache]", :immediately
  only_if { node[:platform] =~ /redhat|centos/ && !::File.exists?(touchfile) }
end

# Installs the Puppet Client specific to the user provided version.
node[:puppet][:client][:packages].each do |pkg|
  package pkg do
    version node[:puppet][:client][:version]
  end
end

# Configures to enable init process to start Puppet client service on Ubuntu.
execute "configure puppet to start" do
  command "sed -i 's/START=no/START=yes/g' /etc/default/puppet"
  only_if { node[:platform] == "ubuntu" && !::File.exists?(touchfile) }
end

# Initializing supported commands for Puppet service for further usage.
service "puppet" do
  action :nothing
  persist true
  supports :status => true, :start => true, :stop => true, :restart => true
end

# Creates the Puppet Client configuration file.
template "/etc/puppet/puppet.conf" do
  source "puppet_client.conf.erb"
  mode "0644"
  backup false
  cookbook "puppet"
  variables(
    :master_address => node[:puppet][:client][:puppet_master_address],
    :node_name => node[:puppet][:client][:node_name],
    :master_port => node[:puppet][:client][:puppet_master_port],
    :environment => node[:puppet][:client][:environment]
  )
end

# Performs certificate registration on the Puppet Master. Interprets exit code 0
# or 2 as success. Logs the warning message on exit code 1.
execute "run puppet-client" do
  command "puppet agent --test"
  returns [0,1,2]
  creates touchfile
  notifies :create, "ruby_block[registration-status]"
end

ruby_block "registration-status" do
  block do
    if File.exists?(touchfile)
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

# Enables and starts the Puppet client service.
service "puppet" do
  action [ :enable, :start ]
  only_if { ::File.exists?(touchfile) }
end
