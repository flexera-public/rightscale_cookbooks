#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Copy Chef Client installation script from cookbook files.
# Sourced from https://www.opscode.com/chef/install.sh
cookbook_file "/tmp/install.sh" do
  source "install.sh"
  mode "0755"
  cookbook "chef"
end

# Installs the Chef Client using user selected version.
execute "install chef client" do
  command "/tmp/install.sh -v #{node[:chef][:client][:version]}"
end

log "  Chef Client version #{node[:chef][:client][:version]} installation is" +
  " completed."

# Creates the Chef Client configuration directory.
directory node[:chef][:client][:config_dir]

# Creates the Chef Client configuration file.
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

# Creates the private key to register the Chef Client with the Chef Server.
template "#{node[:chef][:client][:config_dir]}/validation.pem" do
  source "validation_key.erb"
  mode "0600"
  backup false
  cookbook "chef"
  variables(
    :validation_key => node[:chef][:client][:validator_pem]
  )
end

# Creates runlist.json file.
template "#{node[:chef][:client][:config_dir]}/runlist.json" do
  source "runlist.json.erb"
  cookbook "chef"
  mode "0440"
  backup false
  variables(
    :node_name => node[:chef][:client][:node_name],
    :environment => node[:chef][:client][:environment],
    :company => node[:chef][:client][:company],
    :roles => node[:chef][:client][:roles]
  )
end

# Sets current roles for future validation. See recipe chef::do_client_converge.
node[:chef][:client][:current_roles] = node[:chef][:client][:roles]

log "  Chef Client configuration is completed."

# Sets command extensions and attributes.
extension = "-j #{node[:chef][:client][:config_dir]}/runlist.json -E #{node[:chef][:client][:environment]}"
extension << " -o #{node[:chef][:client][:json_attributes]}" \
  unless node[:chef][:client][:json_attributes].empty?

# Runs the Chef Client using command extensions.
execute "run chef-client" do
  command "chef-client #{extension}"
end

log "  Chef Client role(s) are: #{node[:chef][:client][:current_roles]}"

rightscale_marker :end
