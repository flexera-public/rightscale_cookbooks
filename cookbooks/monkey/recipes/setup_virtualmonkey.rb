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
    "default" => [ "libxml2-dev", "libxml-ruby", "libxslt-ruby", "libxslt1-dev", "libmagic-dev" ]
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
  EOH
end

# Obtaining the built version of VirtualMonkey gem

log "  Obtaining the built version of VirtualMonkey gem"
ruby_block "Obtaining the version of built virtualmonkey gem" do
  block do
    node[:monkey][:virtualmonkey][:version] = File.open("/root/virtualmonkey/VERSION", "r").read.chomp
    Chef::Log.info "virtualmonkey version is: #{node[:monkey][:virtualmonkey][:version]}"
  end
  only_if { ::File.exists?("/root/rest_connection/VERSION") }
end 

# Installing the VirtualMonkey gem

log "  Installing the VirtualMonkey gem version #{node[:monkey][:virtualmonkey][:version]}"
gem_package "virtualmonkey" do
  gem_binary "/usr/bin/gem"
  source "/root/virtualmonkey/pkg/virtualmonkey-#{node[:monkey][:virtualmonkey][:version]}.gem"
  action :install
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

log "  Checking out VirtualMonkey collateral repo from #{node[:monkey][:virtualmonkey][:collateral_repo_url]} and setting up"
bash "Checkout virtualmonkey collateral project" do
  flags "-ex"
  code <<-EOH
    collat_name=`basename "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" ".git"`
    cd /root/virtualmonkey
    bin/monkey collateral clone "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" $collat_name
  EOH
end

#git "/root/virtualmonkey/collateral/servertemplate_tests" do
#  repository node[:monkey][:virtualmonkey][:collateral_repo_url]
#  reference node[:monkey][:virtualmonkey][:collateral_repo_branch]
#  action :sync
#end

rightscale_marker :end
