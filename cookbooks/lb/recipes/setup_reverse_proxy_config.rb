# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Install required apache modules
apache_modules = ["proxy_http", "proxy", "proxy_balancer", "proxy_connect"]
apache_modules.each do |m|
  apache_module m
end

web_app "rightscale-reverse-proxy.vhost" do
  template "rightscale-reverse-proxy.vhost.erb"
  cookbook node[:lb][:service][:provider]
end

rightscale_marker :end
