#
# Cookbook Name:: ruby
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version = Mixlib::ShellOut.new("ruby --version")
version.run_command.error!

if version.stdout =~ /1.9/
  log "  Ruby #{version.stdout} is already installed on this system."
elsif node[:platform] =~ /ubuntu/

  packages = [
    "ruby1.9.1-full",
    "rubygems"
  ]

  packages.each do |pkg|
    package pkg
  end

  bash "Use ruby 1.9" do
    code <<-EOH
      update-alternatives --set ruby "/usr/bin/ruby1.9.1"
      update-alternatives --set gem "/usr/bin/gem1.9.1"
    EOH
  end

  version.run_command.error!
  log "  Installed system ruby version is: #{version.stdout}"
else
  raise "Platform #{node[:platform]} is not supported by this recipe."
end

rightscale_marker :end
