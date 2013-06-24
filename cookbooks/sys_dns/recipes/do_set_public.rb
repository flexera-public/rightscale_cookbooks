# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

public_ip = node[:cloud][:public_ips][0]

# See cookbooks/rightscale/libraries/helper.rb for the "is_valid_ip?" method.
raise "No valid public IP address found for the server" \
  unless RightScale::Utils::Helper.is_valid_ip?(public_ip)

# This will set the DNS record identified by the "DNS Record ID" input to the
# first public IP address of the instance.
#
sys_dns "default" do
  id node[:sys_dns][:id]
  address public_ip
  region node[:sys_dns][:region]
  action :set
end
