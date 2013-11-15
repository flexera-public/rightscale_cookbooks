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

# Sending request to application servers, to remove iptables rule
# that allowed connection from loadbalancer.

# Grab the public and private IPs of the current instance to send
# to the remote recipe.
lb_private_ip = node[:cloud][:private_ips][0]
lb_public_ip = node[:cloud][:public_ips][0]

pool_names(node[:lb][:pools]).each do |pool_name|
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Chef_Resources#RemoteRecipe
  # for the "remote_recipe" resource.
  remote_recipe "Removing loadbalancers from app servers firewall" do
    recipe "app::handle_loadbalancers_deny"
    recipients_tags "loadbalancer:#{pool_name}=app"
    attributes ({
      :app => {
        :lb_private_ip => lb_private_ip,
        :lb_public_ip => lb_public_ip
      }
    })
  end

  # Searches for servers with the 'server_template:version' tag in the
  # deployment and gets their versions.
  # See cookbooks/app/libraries/helper.rb
  # for the "get_rsb_app_servers_version" method.
  versions = get_rsb_app_servers_version
  # Runs remote RightScripts on the found servers to close the firewall port
  # which was open for the LoadBalancer.
  versions.each do |version|
    cmd = "rs_run_right_script"
    cmd << " --name 'LB Setup firewall rule deny (#{version})'"
    cmd << " --recipient_tags 'loadbalancer:#{pool_name}=app"
    cmd << " server_template:version=#{version}'"
    cmd << " --parameter 'LB_ALLOW_DENY_PRIVATE_IP=text:#{lb_private_ip}'"
    cmd << " --parameter 'LB_ALLOW_DENY_PUBLIC_IP=text:#{lb_public_ip}'"
    cmd << " --parameter 'LB_ALLOW_DENY_POOL_NAME=text:#{pool_name}'"

    remote_rs = Mixlib::ShellOut.new(cmd)
    remote_rs.run_command
    log remote_rs.stdout
    log remote_rs.stderr unless remote_rs.exitstatus == 0
    remote_rs.error!
  end
end
