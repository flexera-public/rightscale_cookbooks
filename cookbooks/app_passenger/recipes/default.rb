#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for rails-passenger."
node[:app][:provider] = "app_passenger"

case node[:platform]
  when "ubuntu"
    node[:app][:packages] = [
      "libopenssl-ruby",
      "libcurl4-openssl-dev",
      "apache2-mpm-prefork",
      "apache2-prefork-dev",
      "libapr1-dev",
      "libcurl4-openssl-dev"
     ]
  when "centos","redhat"
    node[:app][:packages] = [
      "zlib-devel",
      "openssl-devel",
      "readline-devel",
      "curl-devel",
      "httpd-devel",
      "apr-devel",
      "apr-util-devel",
      "readline-devel"
     ]
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
node[:app][:root] = node[:app][:destination] + "/public"

rightscale_marker :end
