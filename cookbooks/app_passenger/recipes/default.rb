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
    node[:app][:user] = "www-data"
    node[:app][:group] = "www-data"
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
    node[:app][:user] = "apache"
    node[:app][:group] = "apache"
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
  end

# Setting passenger binary directory
node[:app_passenger][:passenger_bin_dir] = value_for_platform(
  "ubuntu" => {
    "12.04" => "/usr/local/bin/",
    "default" => "/usr/bin/"
  },
  "default" => "/usr/bin/"
)

# Path to Ruby gem directory
node[:app_passenger][:ruby_gem_base_dir] = value_for_platform(
  "ubuntu" => {
    "12.04" => "/var/lib/gems/1.8/",
    "default" => "/usr/lib64/ruby/gems/1.8"
  },
    "default" => "/usr/lib64/ruby/gems/1.8"
)

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
node[:app][:root] = node[:app][:destination] + "/public"

rightscale_marker :end
