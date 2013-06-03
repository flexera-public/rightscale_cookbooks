#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

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

# Copy the rocketmonkey configuration files if they are not present
log "  Copy rocketmonkey configuration files"
[
  "googleget.yaml",
  "rocketmonkey.yaml",
  "rocketmonkey.clouds.yaml",
  "rocketmonkey.regexs.yaml"
].each do |config_file|
  execute "copy '#{config_file}' to '.#{config_file}'" do
    cwd node[:monkey][:rocketmonkey_path]
    command "cp #{config_file} .#{config_file}"
    not_if { ::File.exists?("#{node[:monkey][:rocketmonkey_path]}/.#{config_file}") }
  end
end

log "  Installing required gems for rocketmonkey"
execute "Install rocketmonkey gem dependencies" do
  cwd node[:monkey][:rocketmonkey_path]
  command "bundle install --system"
end

rightscale_marker :end
