#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Send request to chef server to unregister this instance/node.
knife_args = node[:chef][:client][:node_name] +
  " --yes" +
  " --user #{node[:chef][:client][:validation_name]}" +
  " --key #{node[:chef][:client][:config_dir]}/validation.pem" +
  " --config #{node[:chef][:client][:config_dir]}/client.rb"

execute "delete node from chef server" do
  command "knife node delete #{knife_args}" 
end

execute "delete client from chef server" do
  command "knife client delete #{knife_args}" 
end

log "  Chef client unregistered from chef server"

# Remove chef-client files to prevent converge from reconnecting
["client.db", "validation.pem", "runlist.json"].each do |filename|
  file "#{node[:chef][:client][:config_dir]}/#{filename}" do
    action :delete
  end
end
