#
# Cookbook Name:: ruby
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

version = Mixlib::ShellOut.new("ruby --version")
version.run_command.error!

if version.stdout =~ /1\.9/
  log "  Ruby #{version.stdout} is already installed on this system."
elsif node[:platform] =~ /ubuntu/

  # Installs ruby 1.9 with rubygems.
  ["ruby1.9.1-full", "rubygems"].each do |pkg|
    package pkg
  end

  # Ubuntu can have multiple versions of ruby installed. Just need to run
  # 'update-alternatives' to have the OS know which version to use.
  bash "Use ruby 1.9" do
    code <<-EOH
      update-alternatives --set ruby "/usr/bin/ruby1.9.1"
      update-alternatives --set gem "/usr/bin/gem1.9.1"
    EOH
  end

else
  raise "Platform #{node[:platform]} is not supported by this recipe."
end
