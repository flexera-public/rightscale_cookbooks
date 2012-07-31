#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

# Sending request to application servers, to add iptables rule, which will allow connection with loadbalancer

attrs = {:app => Hash.new}
attrs[:app][:lb_ip] = node[:cloud][:private_ips][0]

vhosts(node[:lb][:pool_names]).each_key do | pool_name |
  remote_recipe "Update app servers firewall" do
    recipe "app::handle_loadbalancers_allow"
    recipients_tags "loadbalancer:#{pool_name}=app"
    attributes attrs
  end
end

rightscale_marker :end
