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

attrs = {:app => Hash.new}
attrs[:app][:lb_ip] = node[:cloud][:private_ips][0]

pool_names(node[:lb][:pools]).each do | pool_name |
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RemoteRecipe for the "remote_recipe" resource.
  remote_recipe "Removing loadbalancers from app servers firewall" do
    recipe "app::handle_loadbalancers_deny"
    recipients_tags "loadbalancer:#{pool_name}=app"
    attributes attrs
  end
end

rightscale_marker :end
