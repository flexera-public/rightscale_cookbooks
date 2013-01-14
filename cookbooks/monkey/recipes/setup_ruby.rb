#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# On CentOS 6.3 images uninstall ruby 1.9 version and install ruby 1.8
# On Ubuntu 12.04 images use update-alternatives cmd and choose ruby 1.8
if node[:platform] =~ /centos|redhat/
  ruby_packages = ["ruby", "ruby-libs"]
  ruby_packages.each do |p|
    r = package p do
      action :nothing
    end
    r.run_action(:remove)
  end

  # Install ruby 1.8 using bash block instead of package resource because
  # we can use wildcard to install the latest ruby 1.8 patch level.
  # Package resource requires ruby version to be hardcoded which won't
  # scale very well.
  r = bash "install ruby 1.8" do
    code <<-EOH
    yum install ruby-1.8.* --assumeyes
    EOH
    action :nothing
  end
  r.run_action(:run)

  # Install Rubygems
  r = package "rubygems" do
    action :nothing
  end

elsif node[:platform] =~ /ubuntu/
  ruby_packages = ["ruby1.8", "rubygems"]
  ruby_packages.each do |p|
    r = package p do
      action :nothing
    end
    r.run_action(:install)
  end
  r = bash "use ruby 1.8 version" do
    code <<-EOH
    update-alternatives --set ruby "/usr/bin/ruby1.8"
    update-alternatives --set gem "/usr/bin/gem1.8"
    EOH
    action :nothing
  end
  r.run_action(:run)
end

ruby_dev_pkg = value_for_platform(
  ["centos", "redhat"] => {
     "default" => "ruby-devel"
   },
  "ubuntu" => {
    "default" => "ruby-dev"
  }
)
log "  Verifying installation of #{ruby_dev_pkg}"
package ruby_dev_pkg


rightscale_marker :end
