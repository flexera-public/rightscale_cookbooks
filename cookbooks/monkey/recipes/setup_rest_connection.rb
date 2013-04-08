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

bash "Update Rubygems" do
  flags "-ex"
  code <<-EOH
    gem update --system --no-rdoc --no-ri
  EOH
  not_if { node[:platform] == "ubuntu"  }
end

# Install rubygems 1.8.24. By default rubygems 2.x.x gets installed.
gem_package "rubygems-update" do
  gem_binary "/usr/bin/gem"
  version "1.8.24"
end

update_rubygems = Mixlib::ShellOut("/usr/bin/update_rubygems")
update_rubygems.run_command
update_rubygems.error!

log update_rubygems.stdout

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

git "/root/rest_connection" do
  repository node[:monkey][:rest][:repo_url]
  reference node[:monkey][:rest][:repo_branch]
  action :sync
end

# By default chef changes the checked out branch to a branch named 'deploy' locally
# To make sure we can pull/push changes, let's checkout the correct branch again!

log "  Making super sure that we're on the right branch"
execute "git checkout" do
   cwd "/root/rest_connection"
   command "git checkout #{node[:monkey][:rest][:repo_branch]}"
end

bash "Building and installing rest_connection gem" do
  code <<-EOH
    cd /root/rest_connection
    bundle install
  EOH
end

log "  Creating rest_connection configuration directory"
directory "/root/.rest_connection" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end


template "/root/.rest_connection/rest_api_config.yaml" do
  source "rest_api_config.yaml.erb"
  variables(
    :right_passwd => node[:monkey][:rest][:right_passwd],
    :right_email => node[:monkey][:rest][:right_email],
    :right_acct_id => node[:monkey][:rest][:right_acct_id]
  )
  cookbook "monkey"
end

bash "Adding private ssh key" do
  code <<-EOH
    echo "#{node[:monkey][:rest][:ssh_key]}" > /root/.ssh/api_user_key
    chmod 600 /root/.ssh/api_user_key
    cat << EOF >> /root/.rest_connection/rest_api_config.yaml
:ssh_keys:
- /root/.ssh/api_user_key
EOF
EOH
end unless node[:monkey][:rest][:ssh_key] == ""

bash "Adding optional public ssh key ro authorized keys" do
  code <<-EOH
  echo "#{node[:monkey][:rest][:ssh_pub_key]}" >> /root/.ssh/authorized_keys
  EOH
end unless node[:monkey][:rest][:ssh_pub_key] == ""

rightscale_marker :end
