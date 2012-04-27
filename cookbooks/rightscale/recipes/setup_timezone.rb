#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Set the Timezone
#
if node[:rightscale][:timezone]
  
  rightscale_marker :begin

  link "/etc/localtime" do
    to "/usr/share/zoneinfo/#{node[:rightscale][:timezone]}"
  end

  log "Timezone set to #{node[:rightscale][:timezone]}"

else 

  # If this attribute is not set leave unchanged and use localtime
  log "rightscale/timezone set to localtime.  Not changing /etc/localtime..."
  
  rightscale_marker :end
  
end

