#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

class Chef::Recipe
  include RightScale::App::Helper
end

# Sending request to application servers, to add iptables rule,
# which will allow connection with loadbalancer

attrs = {:app => Hash.new}
# Grab the public and private IPs of the current instance to send
# to the remote recipe.
attrs[:app][:lb_private_ip] = node[:cloud][:private_ips][0]
attrs[:app][:lb_public_ip] = node[:cloud][:public_ips][0]

pool_names(node[:lb][:pools]).each do |pool_name|
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Chef_Resources#RemoteRecipe
  # for the "remote_recipe" resource.
  remote_recipe "Update app servers firewall" do
    recipe "app::handle_loadbalancers_allow"
    recipients_tags "loadbalancer:#{pool_name}=app"
    attributes attrs
  end

  # Searches for any RightScript-based ServerTemplate Application servers
  # in the deployment and gets their versions.
  versions = get_rsb_app_servers_version(pool_name)
  # Runs remote RightScripts on the found servers to open a firewall port for
  # the LoadBalancer.
  versions.each do |version|
    cmd = "rs_run_right_script"
    cmd << " --name 'LB Setup firewall rule allow (#{version})'"
    cmd << " --recipient_tags 'loadbalancer:#{pool_name}=app"
    cmd << " server_template:version=#{version}'"
    cmd << " --parameter 'LB_PRIVATE_IP=text:#{node[:cloud][:private_ips][0]}'"
    cmd << " --parameter 'LB_PUBLIC_IP=text:#{node[:cloud][:public_ips][0]}'"

    remote_rs = Mixlib::ShellOut.new(cmd)
    remote_rs.run_command
    log remote_rs.stdout
    log remote_rs.stderr unless remote_rs.exitstatus == 0
    remote_rs.error!
  end
end
