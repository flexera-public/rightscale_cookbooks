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

# Adding iptables rule to disable loadbalancers <-> application servers connections
# See cookbooks/sys_firewall/providers/default.rb for the "update" action.
pool_names(node[:lb][:pools]).each do | pool_name |
  # See cookbooks/sys_firewall/resources/default.rb for the "sys_firewall" resource.
  sys_firewall "Close this appserver's ports to all loadbalancers" do
    machine_tag "loadbalancer:#{pool_name}=lb"
    port node[:app][:port].to_i
    enable false
    action :update
  end
end

rightscale_marker :end
