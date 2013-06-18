#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Install the jenkins server
# See cookbooks/jenkins/recipes/install_server for the "jenkins::install_server"
# recipe.
include_recipe "jenkins::install_server"

log "  Checking out Rocketmonkey repository from:" +
  " #{node[:monkey][:rocketmonkey][:repo_url]}"
git node[:monkey][:rocketmonkey_path] do
  repository node[:monkey][:rocketmonkey][:repo_url]
  reference node[:monkey][:rocketmonkey][:repo_branch]
  action :sync
end

execute "git checkout" do
  cwd node[:monkey][:rocketmonkey_path]
  command "git checkout #{node[:monkey][:rocketmonkey][:repo_branch]}"
end

# The rocketmonkey main configuration file is created from a template initially
# allowing custom edits on the configuration. This template file is not
# completely controlled by Chef yet.
#
template "#{node[:monkey][:rocketmonkey_path]}/.rocketmonkey.config" do
  source "rocketmonkey_config.yaml.erb"
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode 0644
  variables(
    :jenkins_user => node[:jenkins][:server][:user_name],
    :jenkins_password => node[:jenkins][:server][:password],
    :right_acct_id => node[:monkey][:rest][:right_acct_id],
    :right_subdomain => node[:monkey][:rest][:right_subdomain]
  )
  action :create_if_missing
end

# Copy the rocketmonkey configuration files if they are not present. Presently,
# these configuration files are not managed by Chef.
log "  Creating rocketmonkey configuration files from tempaltes"
[
  "googleget.yaml",
  "rocketmonkey.clouds.yaml",
  "rocketmonkey.regexs.yaml"
].each do |config_file|
  execute "copy '#{config_file}' to '.#{config_file}'" do
    cwd node[:monkey][:rocketmonkey_path]
    command "cp #{config_file} .#{config_file}"
    not_if do
      ::File.exists?("#{node[:monkey][:rocketmonkey_path]}/.#{config_file}")
    end
  end
end

log "  Installing required gems for rocketmonkey"
execute "Install rocketmonkey gem dependencies" do
  cwd node[:monkey][:rocketmonkey_path]
  command "bundle install --system"
end
