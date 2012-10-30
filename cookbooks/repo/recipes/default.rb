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
  account = entry[:account] || ""
  credential = entry[:credential] || ""
  storage_account_provider = entry[:storage_account_provider] || ""
  prefix = entry[:prefix] || ""

  # Initial setup of "repository" LWRP.
  log "  Registering #{resource_name} prov: #{entry[:provider]}"
  # See cookbooks/repo/resources/default.rb for the "repo" resource.
  repo resource_name do
    provider entry[:provider]
    repository url
    revision branch
    account account
    credential credential
    storage_account_provider storage_account_provider
    prefix prefix
    unpack_source true
    persist true
  end
end

rightscale_marker :end
