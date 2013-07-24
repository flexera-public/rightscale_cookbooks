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

# Creates the YAML file with credentials for "check_smtp" test for the
# "lamp_chef" feature.
directory "#{node[:monkey][:user_home]}/.virtualmonkey" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
end

template "#{node[:monkey][:user_home]}/.virtualmonkey/test_creds.yaml" do
  source "test_creds.yaml.erb"
  owner node[:monkey][:user]
  group node[:monkey][:group]
  variables(
    :smtp_username => node[:monkey][:test][:smtp_username],
    :smtp_password => node[:monkey][:test][:smtp_password]
  )
  mode 0600
end
