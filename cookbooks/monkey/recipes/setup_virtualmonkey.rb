#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

node[:monkey][:virtualmonkey][:packages] = value_for_platform(
  "centos" => {
    "default" => ["libxml2-devel", "libxslt-devel", "file"]
  },
  "ubuntu" => {
    "default" => ["libxml2-dev", "libxml-ruby", "libxslt1-dev", "libmagic-dev"]
  }
)

# Installing packages required by VirtualMonkey
log "  Installing packages required by VirtualMonkey"
packages = node[:monkey][:virtualmonkey][:packages]
packages.each do |pkg|
  package pkg
end unless packages.empty?

# Updating rubygems
log "  Updating rubygems"
bash "Update Rubygems" do
  flags "-ex"
  code <<-EOH
    gem install rubygems-update --version 1.8.24 --no-ri --no-rdoc
    update_rubygems
  EOH
  not_if { node[:platform] == "ubuntu"  }
end

# Checking out VirtualMonkey repository
log "  Checking out VirtualMonkey repository from:" +
  " #{node[:monkey][:virtualmonkey][:monkey_repo_url]}"
git node[:monkey][:virtualmonkey_path] do
  repository node[:monkey][:virtualmonkey][:monkey_repo_url]
  reference node[:monkey][:virtualmonkey][:monkey_repo_branch]
  action :sync
end

# By default chef changes the checked out branch to a branch named 'deploy'
# locally. To make sure we can pull/push changes, let's checkout the correct
# branch again!
#
log "  Making super sure that we're on the right branch"
execute "git checkout" do
  cwd node[:monkey][:virtualmonkey_path]
  command "git checkout #{node[:monkey][:virtualmonkey][:monkey_repo_branch]}"
end

# Install Virtualmonkey dependencies
log "  Installing Virtualmonkey dependencies"
bash "Install Virtualmonkey dependencies" do
  flags "-ex"
  code <<-EOH
    cd #{node[:monkey][:virtualmonkey_path]}
    bundle install --no-color --system
  EOH
end

# Copy the virtualmonkey configuration file
execute "Copy Virtualmonkey configuration" do
  command "cp #{node[:monkey][:virtualmonkey_path]}/config.yaml" +
    " #{node[:monkey][:virtualmonkey_path]}/.config.yaml"
end

# Add virtualmonkey to PATH
file "/etc/profile.d/virtualmonkey.sh" do
  owner "root"
  group "root"
  mode 0755
  content "export PATH=#{node[:monkey][:virtualmonkey_path]}/bin:$PATH"
  action :create
end

# Installing right_cloud_api gem from the template file found in rightscale
# cookbook. The rightscale::install_tools installs this gem in sandbox ruby
# and I want it in system ruby
#
log "  Installing the right_cloud_api gem"
gem_package "right_cloud_api" do
  gem_binary "/usr/bin/gem"
  source ::File.join(
    ::File.dirname(__FILE__),
    "..",
    "..",
    "rightscale",
    "files",
    "default",
    "right_cloud_api-0.0.0.gem"
  )
  action :install
end

log "  Obtaining collateral project name from repo URL"
ruby "Obtaining Collateral Project name" do
  node[:monkey][:virtualmonkey][:collateral_name] =
    `basename "#{node[:monkey][:virtualmonkey][:collateral_repo_url]}" ".git"`.chomp
end

log "  Checking out collateral repo to #{node[:monkey][:virtualmonkey][:collateral_name]}"
git "/root/#{node[:monkey][:virtualmonkey][:collateral_name]}" do
  repository node[:monkey][:virtualmonkey][:collateral_repo_url]
  reference node[:monkey][:virtualmonkey][:collateral_repo_branch]
  action :sync
end

log "  Making super sure that we're on the right branch"
execute "git checkout" do
  cwd "/root/#{node[:monkey][:virtualmonkey][:collateral_name]}"
  command "git checkout #{node[:monkey][:virtualmonkey][:collateral_repo_branch]}"
end

log "  Installing gems required for the collateral project"
execute "bundle install on collateral" do
  cwd "/root/#{node[:monkey][:virtualmonkey][:collateral_name]}"
  command "bundle install --no-color --system"
end

rightscale_marker :end
