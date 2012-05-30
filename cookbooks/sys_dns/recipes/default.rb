#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing packages depending on platform
package value_for_platform(
  [ "ubuntu", "debian" ] => { "default" => "libdigest-sha1-perl" },
  [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-SHA1" }
)

package value_for_platform(
  [ "ubuntu", "debian" ] => { "default" => "libdigest-hmac-perl" },
  [ "centos", "redhat", "suse" ] => { "default" => "perl-Digest-HMAC" }
)

# Creating dns directory for further use
directory "/opt/rightscale/dns" do
  owner "root"
  group "root"
  mode "0755"
  recursive true
end

# Defining the cookbook file used for AWS
cookbook_file "/opt/rightscale/dns/dnscurl.pl" do
  source "dnscurl.pl"
  owner "root"
  group "root"
  mode "0755"
  backup false
end

# Setting up appropriate DNS provider
sys_dns "default" do
  provider "sys_dns_#{node[:sys_dns][:choice]}"
  user node[:sys_dns][:user]
  password node[:sys_dns][:password]
  persist true
  action :nothing
end

rightscale_marker :end
