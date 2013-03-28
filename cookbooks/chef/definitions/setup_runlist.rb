#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Creates runlist and runs the Chef client using the same.

define :setup_runlist do

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
      :role => node[:chef][:client][:roles]
    )
  end

  # Runs the Chef client using runlist.json file.
  execute "chef-client -j #{node[:chef][:client][:config_dir]}/runlist.json"

  # Sets current roles for future validation. See recipe chef::execute_runlist.
  node[:chef][:client][:current_roles] = node[:chef][:client][:roles]

  log "  Chef client active role/s: #{node[:chef][:client][:current_roles]}"

end
