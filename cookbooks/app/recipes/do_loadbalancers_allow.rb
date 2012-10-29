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

# Adding iptables rule to allow loadbalancers <-> application servers connections
# See cookbooks/sys_firewall/providers/default.rb for "update" action.
pool_names(node[:lb][:pools]).each do | pool_name |
  sys_firewall "Open this appserver's ports to all loadbalancers" do
    machine_tag "loadbalancer:#{pool_name}=lb"
    port node[:app][:port].to_i
    enable true
    action :update
  end
end

rightscale_marker :end
