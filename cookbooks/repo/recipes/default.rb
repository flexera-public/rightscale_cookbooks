#
# Cookbook Name:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin



log "  Setup all resources that have attributes in the node"
node[:repo].each do |resource_name, entry|

  url = entry[:repository] || ""
  branch = entry[:revision] || ""
  svn_username = entry[:svn_username] || ""
  svn_password = entry[:svn_password] || ""
  key = entry[:ssh_key] || ""
  storage_account_provider = entry[:storage_account_provider] || ""
  storage_account_id = entry[:storage_account_id] || ""
  storage_account_secret = entry[:storage_account_secret] || ""
  container = entry[:container] || ""
  prefix = entry[:prefix] || ""

  # Checking for ros_util presence it is required for repo_ros correct operations
  ruby_block "Checking for ros_util presence" do
    block do
      raise "  Error: ROS gem missing, please add rightscale::install_tool recipe to runlist." unless File.exists?("/opt/rightscale/sandbox/bin/ros_util")
    end
    only_if do (entry[:provider]=="repo_ros") end
  end

  # Initial setup of "repository" LWRP.
  log "  Registering #{resource_name} prov: #{entry[:provider]}"
  repo resource_name do
    provider entry[:provider]
    repository url
    revision branch
    git_ssh_key key
    svn_username svn_username
    svn_password svn_password
    storage_account_provider storage_account_provider
    storage_account_id storage_account_id
    storage_account_secret storage_account_secret
    container container
    unpack_source true
    prefix prefix
    persist true
  end
end

rightscale_marker :end
