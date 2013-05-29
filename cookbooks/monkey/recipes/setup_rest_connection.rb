#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing packages needed for rest_connection
node[:monkey][:rest][:packages] = value_for_platform(
  "centos" => {
    "default" => [ "libxml2-devel",  "libxslt-devel"]
  },
  "ubuntu" => {
    "default" => [ "libxml2-dev", "libxslt1-dev" ]
  }
)

packages = node[:monkey][:rest][:packages]
log "  Installing packages required by rest_connection"
packages.each do |pkg|
  package pkg
end unless packages.empty?

# Install rubygems compatible with Ruby 1.8.7. By default rubygems 2.x.x gets
# installed.
gem_package "rubygems-update" do
  gem_binary "/usr/bin/gem"
  version node[:monkey][:rubygems_update_version]
  action :install
end

# Set the update rubygems command based on the platform
update_rubygems_cmd =
  case node[:platform]
  when "ubuntu"
    "/usr/local/bin/update_rubygems"
  else
    "/usr/bin/update_rubygems"
  end

execute "update rubygems" do
  command update_rubygems_cmd
end

# Installing gem dependencies
log "  Installing gems requierd by rest_connection"
gems = node[:monkey][:rest][:gem_packages]
gems.each do |gem|
  gem_package gem[:name] do
    gem_binary "/usr/bin/gem"
    version gem[:version]
    action :install
  end
end unless gems.empty?

# Checkout the rest_connection project. The code is just checked out for
# performing development. This code is not installed. The Gemfile in
# virtualmonkey and rocketmonkey determine the version they require for
# rest_connection.
#
git node[:monkey][:rest_connection_path] do
  repository node[:monkey][:rest][:repo_url]
  reference node[:monkey][:rest][:repo_branch]
  action :sync
end

# By default chef changes the checked out branch to a branch named 'deploy' locally
# To make sure we can pull/push changes, let's checkout the correct branch again!

log "  Making super sure that we're on the right branch"
execute "git checkout" do
   cwd node[:monkey][:rest_connection_path]
   command "git checkout #{node[:monkey][:rest][:repo_branch]}"
end

log "  Creating rest_connection configuration directory"
directory "#{node[:monkey][:user_home]}/.rest_connection" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode "0755"
  action :create
end


template "#{node[:monkey][:user_home]}/.rest_connection/rest_api_config.yaml" do
  source "rest_api_config.yaml.erb"
  variables(
    :right_passwd => node[:monkey][:rest][:right_passwd],
    :right_email => node[:monkey][:rest][:right_email],
    :right_acct_id => node[:monkey][:rest][:right_acct_id],
    :right_subdomain => node[:monkey][:rest][:right_subdomain]
  )
  cookbook "monkey"
end

# Create the private key used for SSH
file "#{node[:monkey][:user_home]}/.ssh/api_user_key" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode 0600
  content node[:monkey][:rest][:ssh_key]
  action :create
end

# Add the private key to the rest_connection configuration file
bash "Adding private ssh key to rest_connection config" do
  code <<-EOH
    cat << EOF >> #{node[:monkey][:user_home]}/.rest_connection/rest_api_config.yaml
:ssh_keys:
- #{node[:monkey][:user_home]}/.ssh/api_user_key
EOF
EOH
end

# Create the authorized_keys file if it doesn't exist
file "#{node[:monkey][:user_home]}/.ssh/authorized_keys" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode 0644
  action :create
end

execute "add public key to authorized keys" do
  command "echo #{node[:monkey][:rest][:ssh_pub_key]} >>" +
    " #{node[:monkey][:user_home]}/.ssh/authorized_keys"
  not_if { File.open("#{ENV['HOME']}/.ssh/authorized_keys").lines.any? { |line| line.chomp == node[:jenkins][:public_key] } }
end unless node[:monkey][:rest][:ssh_pub_key].empty?

rightscale_marker :end
