#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Creates the Chef client configuration directory.
directory node[:chef][:client][:config_dir]

# Creates the Chef client configuration file.
template "#{node[:chef][:client][:config_dir]}/client.rb" do
  source "chef_client_conf.erb"
  mode "0644"
  backup false
  cookbook "chef"
  variables(
    :server_url => node[:chef][:client][:server_url],
    :validation_name => node[:chef][:client][:validation_name],
    :node_name => node[:chef][:client][:node_name]
  )
end

# Creates the Chef client private ssh key.
template "#{node[:chef][:client][:config_dir]}/validation.pem" do
  source "private_ssh_key.erb"
  mode "0644"
  backup false
  cookbook "chef"
  variables :private_ssh_key => node[:chef][:client][:private_ssh_key]
end

# Creates the Chef client runlist.json file.
# See cookbooks/chef/definitions/setup_runlist.rb for the "setup_runlist"
# definition.
setup_runlist

log "  Chef client configuration is completed"

rightscale_marker :end
