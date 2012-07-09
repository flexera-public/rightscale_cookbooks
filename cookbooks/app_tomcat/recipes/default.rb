#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version = node[:app_tomcat][:version]

case version
when '6', '7'
  include_recipe "app_tomcat::default_#{version.gsub('.', '_')}"
else
  raise "Unsupported Tomcat version: #{version}"
end

rightscale_marker :end
