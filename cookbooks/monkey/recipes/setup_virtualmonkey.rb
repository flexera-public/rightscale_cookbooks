#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

node[:monkey][:virtualmonkey][:packages] = value_for_platform(
  "centos" => {
    "default" => [ "libxml2-devel", "libxslt-devel", "file" ]
  },
  "ubuntu" => {
    "default" => [ "libxml2-dev", "libxml-ruby", "libxslt1-dev", "libmagic-dev" ]
  }
)

# Installing packages required by VirtualMonkey

log "  Installing packages required by VirtualMonkey"
packages = node[:monkey][:virtualmonkey][:packages]
packages.each do |pkg|
  package pkg
end unless packages.empty?

# Creating rubyforge configuration directory

log "  Creating rubyforge configutation directory"
directory "/root/.rubyforge" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

# Creating rubyforge configuration file from template

log "  Creating rubyforge config file from template"
template "/root/.rubyforge/user-config.yml" do
  source "rubyforge_user_config.erb"
  cookbook "monkey"
end

# Updating rubygems

log "  Updating rubygems"
bash "Update Rubygems" do
  flags "-ex"
  code <<-EOH
    gem update --system --no-rdoc --no-ri
  EOH
  not_if { node[:platform] == "ubuntu"  }
end

# Installing gems required by VirtualMonkey

log "  Installing gems required by VirtualMonkey"
gems = node[:monkey][:virtualmonkey][:gem_packages]
gems.each do |gem|
  gem_package gem do
    gem_binary "/usr/bin/gem"
    action :install
  end
end unless gems.empty?

# Checking out VirtualMonkey repository

log "  Checking out VirtualMonkey repository from: #{node[:monkey][:virtualmonkey][:monkey_repo_url]}"
git "/root/virtualmonkey" do
  repository node[:monkey][:virtualmonkey][:monkey_repo_url]
  reference node[:monkey][:virtualmonkey][:monkey_repo_branch]
  action :sync
end

# Building VirtualMonkey gem

log "  Building VirtualMonkey gem"
bash "Building virtualmonkey gem" do
  flags "-ex"
  code <<-EOH
    cd /root/virtualmonkey
    rake build
    gem install pkg/virtualmonkey-*.gem --no-rdoc --no-ri
  EOH
end

# Installing right_cloud_api gem from the template file found in rightscale cookbook
# The rightscale::install_tools installs this gem in sandbox ruby and I want it in system ruby

log "  Installing the right_cloud_api gem"
gem_package "right_cloud_api" do
  gem_binary "/usr/bin/gem"
  source ::File.join(::File.dirname(__FILE__), "..", "..", "rightscale", "files", "default", "right_cloud_api-0.0.0.gem")
  action :install
end

# Checking out VirtualMonkey collateral repo and setting up

log "  Creating collateral directory"
directory "/root/virtualmonkey/collateral" do
  user "root"
  group "root"
  mode "0755"
  action :create
end

log "  Obtaining collateral project name from repo URL"
ruby "Obtaining Collateral Project name" do
  node[:monkey][:virtualmonkey][:collateral_name] = `basename "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" ".git"`.chomp
end

log "  Checking out collateral repo to #{node[:monkey][:virtualmonkey][:collateral_name]}"
git "/root/virtualmonkey/collateral/#{node[:monkey][:virtualmonkey][:collateral_name]}" do
  repository node[:monkey][:virtualmonkey][:collateral_repo_url]
  reference node[:monkey][:virtualmonkey][:collateral_repo_branch]
  action :sync
end

rightscale_marker :end
