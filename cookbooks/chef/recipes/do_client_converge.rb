#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

log "  Current Chef Client role(s) are: #{node[:chef][:client][:current_roles]}"

# Updates runlist.json file with new roles.
if node[:chef][:client][:current_roles] != node[:chef][:client][:roles]

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

  # Sets current roles for future validation.
  node[:chef][:client][:current_roles] = node[:chef][:client][:roles]
end

# Runs the Chef Client using runlist.json file.
execute "run chef client" do
  command "chef-client -j #{node[:chef][:client][:config_dir]}/runlist.json"
end
