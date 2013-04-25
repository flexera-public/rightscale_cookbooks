#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# This will set the DNS record identified by the “DNS Record ID” input to the first private IP address of the instance.
sys_dns "default" do
  id node[:sys_dns][:id]
  address node[:cloud][:public_ips][0]
  region node[:sys_dns][:region]
  action :set
end

rightscale_marker :end
