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
else
  log "  Cloud setup not required for this cloud #{node[:cloud][:provider]}." +
    " Skipping..."
end

rightscale_marker :end
