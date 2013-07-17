#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

ruby_block "delete_node_and_client" do
  block do
    cmd_args = node[:chef][:client][:node_name]
    cmd_args << " --user #{node[:chef][:client][:node_name]}"
    cmd_args << " --key /etc/chef/client.pem"
    cmd_args << " --server-url #{node[:chef][:client][:server_url]}"
    cmd_args << " --yes"

    # Deletes the node identified by 'node_name' on the Chef Server.
    node_delete = Mixlib::ShellOut.new("knife node delete #{cmd_args}")
    node_delete.run_command
    Chef::Log.info node_delete.stdout
    Chef::Log.info node_delete.stderr unless node_delete.exitstatus == 0
    # Raises an Exception if command execution fails.
    node_delete.error!

    # Deletes the registered client system on the Chef Server.
    client_delete = Mixlib::ShellOut.new("knife client delete #{cmd_args}")
    client_delete.run_command
    Chef::Log.info client_delete.stdout
    Chef::Log.info client_delete.stderr unless client_delete.exitstatus == 0
    # Raises an Exception if command execution fails.
    client_delete.error!
  end
end
