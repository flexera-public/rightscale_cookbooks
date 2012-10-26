#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Removing /system/maintenance.html from apache docroot
log "  Removing #{node[:web_apache][:docroot]}/system/maintenance.html"
file "#{node[:web_apache][:docroot]}/system/maintenance.html" do
  action :delete
  backup false
  only_if do ::File.exists?("#{node[:web_apache][:docroot]}/system/maintenance.html")  end
end

rightscale_marker :end
