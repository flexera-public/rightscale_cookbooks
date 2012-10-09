#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Updating fog credentials"
template "/root/.fog" do
  source "fog.erb"
  variables(
    :aws_access_key_id => node[:monkey][:fog][:aws_access_key_id],
    :aws_secret_access_key => node[:monkey][:fog][:aws_secret_access_key],
    :aws_access_key_id_test => node[:monkey][:fog][:aws_access_key_id_test],
    :aws_secret_access_key_test => node[:monkey][:fog][:aws_secret_access_key_test],
    :rackspace_api_key => node[:monkey][:fog][:rackspace_api_key],
    :rackspace_username => node[:monkey][:fog][:rackspace_username],
    :rackspace_auth_url_uk_test => node[:monkey][:fog][:rackspace_auth_url_uk_test],
    :rackspace_api_uk_key_test => node[:monkey][:fog][:rackspace_api_uk_key_test],
    :rackspace_uk_username_test => node[:monkey][:fog][:rackspace_uk_username_test],
    :aws_publish_key => node[:monkey][:fog][:aws_access_key_id],
    :aws_publish_secret_key => node[:monkey][:fog][:aws_secret_access_key],
    :aws_access_key_id_rstemp => node[:monkey][:fog][:aws_access_key_id_rstemp],
    :aws_secret_access_key_rstemp => node[:monkey][:fog][:aws_secret_access_key_rstemp],
    :softlayer_api_key => node[:monkey][:fog][:softlayer_api_key],
    :softlayer_username => node[:monkey][:fog][:softlayer_username],
    :rackspace_managed_auth_key => node[:monkey][:fog][:rackspace_managed_auth_key],
    :rackspace_managed_username => node[:monkey][:fog][:rackspace_managed_username],
    :google_access_key_id => node[:monkey][:fog][:google_access_key_id],
    :google_secret_access_key => node[:monkey][:fog][:google_secret_access_key],
    :azure_access_key_id => node[:monkey][:fog][:azure_access_key_id],
    :azure_secret_access_key => node[:monkey][:fog][:azure_secret_access_key],
    :azure_endpoint => node[:monkey][:fog][:azure_endpoint],
    :s3_bucket => node[:monkey][:fog][:s3_bucket]
  )
  cookbook "monkey"
end

rightscale_marker :end
