#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# This recipe will run only on the Rackspace Managed Cloud. See
# cookbooks/rightscale/libraries/helper.rb for the "is_rackspace_managed_cloud"
# method.
if RightScale::Utils::Helper.is_rackspace_managed_cloud?
  if node[:rightscale][:rackspace_username].nil? ||
    node[:rightscale][:rackspace_api_key].nil? ||
    node[:rightscale][:rackspace_tenant_id].nil?
    raise "Inputs Rackspace Username, Rackspace API Key, and" +
      " Rackspace Tenant ID are required for setting up the Rackspace Managed" +
      " Cloud."
  end
  log "  Setting up cloud-related functions for #{node[:cloud][:provider]}"

  # Obtains the region of the Rackspace Managed Cloud. See
  # cookbooks/rightscale/libraries/helper.rb for the "get_rackspace_region"
  # method.
  region = RightScale::Utils::Helper.get_rackspace_region

  # Prepare the attributes required for the driveclient cookbook and include
  # the driveclient::default recipe.
  node[:driveclient] ||= {}
  node[:driveclient][:apihostname] =
    case region
    when "lon"
      "api.drivesrvr.co.uk"
    else
      "api.drivesrvr.com"
    end
  node[:driveclient][:username] = node[:rightscale][:rackspace_username]
  node[:driveclient][:password] = node[:rightscale][:rackspace_api_key]
  node[:driveclient][:accountid] = node[:rightscale][:rackspace_tenant_id]
  include_recipe "driveclient::default"

  # Prepare the attributes required for the cloudmonitoring cookbook and
  # include the cloudmonitoring::default recipe.
  node[:cloud_monitoring] ||= {}
  node[:cloud_monitoring][:rackspace_username] =
    node[:rightscale][:rackspace_username]
  node[:cloud_monitoring][:rackspace_api_key] =
    node[:rightscale][:rackspace_api_key]
  node[:cloud_monitoring][:rackspace_auth_region] =
    case region
    when "lon"
      "uk"
    else
      "us"
    end
  include_recipe "cloudmonitoring::default"
else
  log "  Cloud setup is not required for this cloud" +
    " #{node[:cloud][:provider]}. Skipping..."
end

rightscale_marker :end
