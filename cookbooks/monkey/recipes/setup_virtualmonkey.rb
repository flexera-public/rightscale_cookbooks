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

packages = node[:monkey][:virtualmonkey][:packages]
packages.each do |pkg|
  package pkg
end unless packages.empty?

directory "/root/.rubyforge" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/root/.rubyforge/user-config.yml" do
  source "rubyforge_user_config.erb"
  cookbook "monkey"
end

bash "Update Rubygems" do
  flags "-ex"
  code <<-EOH
    gem update --system --no-rdoc --no-ri
  EOH
end

gems = node[:monkey][:virtualmonkey][:gem_packages]
gems.each do |gem|
  gem_package gem do
    gem_binary "/usr/bin/gem"
    action :install
  end
end unless gems.empty?

git "/root/virtualmonkey" do
  repository 'git@github.com:rightscale/virtualmonkey.git'
  reference 'master'
  action :sync
end

bash "Building virtualmonkey gem" do
  flags "-ex"
  code <<-EOH
    cd /root/virtualmonkey
    rake build
  EOH
end

ruby "Obtaining the version of built virtualmonkey gem" do
  node[:monkey][:virtualmonkey][:version] = `cat /root/virtualmonkey/VERSION`
  node[:monkey][:virtualmonkey][:version].chomp!
end

gem_package "virtualmonkey" do
  gem_binary "/usr/bin/gem"
  source "/root/virtualmonkey/pkg/virtualmonkey-#{node[:monkey][:virtualmonkey][:version]}.gem"
  action :install
end

gem_package "right_cloud_api" do
  gem_binary "/usr/bin/gem"
  source ::File.join(::File.dirname(__FILE__), "..", "..", "rightscale", "files", "default", "right_cloud_api-0.0.0.gem")
  action :install
end

bash "Checkout virtualmonkey collateral project" do
  flags "-ex"
  code <<-EOH
    collat_name=`basename "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" ".git"`
    cd /root/virtualmonkey
    bin/monkey collateral clone "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" $collat_name
  EOH
end

rightscale_marker :end
