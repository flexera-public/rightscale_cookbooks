#
# Cookbook Name:: repo_svn
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Install subversion client
package "subversion" do
  action :install
end

extra_packages = case node[:platform]
                 when "ubuntu"
                   if node[:platform_version].to_f < 8.04
                     %w{subversion-tools libsvn-core-perl}
                   else
                     %w{subversion-tools libsvn-perl}
                   end
                 when "centos", "redhat"
                   %w{subversion-devel subversion-perl}
                 end

# Install additional svn packages
extra_packages.each do |pkg|
  package pkg do
    action :install
  end
end

rightscale_marker :end
