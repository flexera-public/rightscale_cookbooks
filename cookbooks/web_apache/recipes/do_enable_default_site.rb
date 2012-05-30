#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Disable default vhost
log "  Enabling default vhost"
apache_site "default" do
  enable true
  notifies :reload, resources(:service => "apache2")
end

rightscale_marker :end
