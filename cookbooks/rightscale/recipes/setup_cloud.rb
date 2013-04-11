#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if RightScale::Utils::Helper.is_rackspace_managed_cloud?
  log "  Setting up cloud-related functions for #{node[:cloud][:provider]}"
  log "  DEBUG: Rackspace Username: #{node[:rightscale][:rackspace_username]}"
  log "  DEBUG: Rackspace API Key: #{node[:rightscale][:rackspace_api_key]}"
  log "  DEBUG: Rackspace Tenant ID: #{node[:rightscale][:rackspace_tenant_id]}"

  log "  DEBUG: Region name: #{RightScale::Utils::Helper.get_rackspace_region}"
  node[:driveclient] ||= {}
  node[:cloud_monitoring] ||= {}
  region = RightScale::Utils::Helper.get_rackspace_region
  node[:driveclient][:apihostname] =
    case region
    when "ord", "dfw"
      "api.drivesrvr.com"
    when "lon"
      "api.drivesrvr.co.uk"
    else
      raise "Unable to detech Rackspace region"
    end
  node[:driveclient][:username] = node[:rightscale][:rackspace_username]
  node[:driveclient][:password] = node[:rightscale][:rackspace_api_key]
  node[:driveclient][:accountid] = node[:rightscale][:rackspace_tenant_id]
  include_recipe "driveclient::default"
else
  log "  Cloud setup not required for this cloud #{node[:cloud][:provider]}." +
    " Skipping..."
end

rightscale_marker :end
