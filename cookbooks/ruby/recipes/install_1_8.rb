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

if version.stdout =~ /1\.8/
  log "  Ruby #{version.stdout} is already installed on this system."
else
  case node[:platform]
  when /centos|redhat/

    # Removes ruby packages that are not 1.8 if they are installed.
    ["ruby", "ruby-libs"].each do |pkg|
      package pkg do
        action :remove
      end
    end

    # Installs ruby 1.8 using bash block instead of package resource because
    # a wildcard is used to install the latest ruby 1.8 patch level.
    # Package resource requires ruby version to be hardcoded which won't
    # scale very well.
    bash "Install ruby 1.8" do
      code "yum install ruby-1.8.* --assumeyes"
    end

    # Installs rubygems.
    package "rubygems"

  when /ubuntu/

    # Installs ruby 1.8 with rubygems.
    ["ruby1.8", "rubygems"].each do |pkg|
      package pkg
    end

    # Ubuntu can have multiple versions of ruby installed. Just need to run
    # 'update-alternatives' to have the OS know which version to use.
    bash "Use ruby 1.8" do
      code <<-EOH
        update-alternatives --set ruby "/usr/bin/ruby1.8"
        update-alternatives --set gem "/usr/bin/gem1.8"
      EOH
    end

  else
    raise "Platform #{node[:platform]} is not supported by this recipe."
  end
end

rightscale_marker :end
