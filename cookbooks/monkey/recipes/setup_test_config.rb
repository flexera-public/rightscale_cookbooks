#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Create the /etc/chef directory if it doesn't exist
directory "/etc/chef" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode 0755
  recursive true
  action :create
end

# Create the Knife PEM Key
file "/etc/chef/rightscalevirtualmonkey.pem" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode 0600
  content node[:monkey][:test_config][:knife_pem_key]
  action :create
end
