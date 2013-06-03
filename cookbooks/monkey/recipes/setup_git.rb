#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Creating ssh directory for root user"
directory "#{node[:monkey][:user_home]}/.ssh" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

log "  Adding git private key for root user"
file "#{node[:monkey][:user_home]}/.ssh/git_id_rsa" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  mode "0600"
  content node[:monkey][:git][:ssh_key]
  action :create
end

# Configuring ssh to add github
log "  Configuring ssh to add github"
template "#{node[:monkey][:user_home]}/.ssh/config" do
  source "sshconfig.erb"
  variables(
    :git_hostname => node[:monkey][:git][:host_name],
    :keyfile => "#{node[:monkey][:user_home]}/.ssh/git_id_rsa"
  )
  cookbook "monkey"
end

# Setting up git configuration for root user
log "  Setting up git configuration for root user"
template "#{node[:monkey][:user_home]}/.gitconfig" do
  source "gitconfig.erb"
  variables(
    :git_user => node[:monkey][:git][:user],
    :git_email => node[:monkey][:git][:email]
  )
  cookbook "monkey"
end

rightscale_marker :end
