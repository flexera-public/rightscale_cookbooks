#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Installs the Puppet repository.
cookbook_file "/tmp/#{node[:puppet][:client][:repo_source]}" do
  source "#{node[:puppet][:client][:repo_source]}"
  mode "0755"
  cookbook "puppet"
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

# Configures to start Puppet on Ubuntu.
execute "configure puppet to start" do
  command "sed -i 's/START=no/START=yes/g' /etc/default/puppet"
  only_if { node[:platform] == "ubuntu" && !::File.exists?(touchfile) }
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

# Configures the Puppet Client service.
service "puppet" do
  action :enable
end

# Executes the Puppet client.
# See cookbooks/puppet/definitions/puppet_client_run.rb for the
# "puppet_client_run" definition.
puppet_client_run
