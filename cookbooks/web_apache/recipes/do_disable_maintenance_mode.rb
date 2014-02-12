#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Removes maintenance.html file.
log "  Removing #{node[:web_apache][:maintenance_file]}"
file node[:web_apache][:maintenance_file] do
  action :delete
  backup false
  only_if { ::File.exists?(node[:web_apache][:maintenance_file]) }
end
