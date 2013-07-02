#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if "#{node[:rightscale][:security_updates]}" == "enable"

  log "  Security updates enabled.  Setting up monitoring."
  platform = node[:platform]
  case platform
  when "ubuntu"
    log "  Install Ubuntu security monitoring package dependencies and plugin"
    package update-notifier-common
    # Install custom collectd plugin
    #
    
  when "centos", "redhat"
    log "  Install CentOS security monitoring package dependencies and plugin"
    log "  ERROR/TBD/XXXX - centos implementation not complete"
  else
    log "  Usupportted OS: #{platform}"
else
  log "  Security updates disabled.  Skipping monitoring setup!"
end
