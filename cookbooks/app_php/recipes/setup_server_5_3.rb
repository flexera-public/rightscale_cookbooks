#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for php application server."
node[:app][:provider] = "app_php"
node[:app][:version] = "5.3"
log "  Setting php application server version to 5.3."

# Setting generic app attributes
case node[:platform]
when "ubuntu"
  node[:app][:user] = "www-data"
  node[:app][:group] = "www-data"
  node[:app][:packages] = [
    "php5",
    "php-pear",
    "libapache2-mod-php5"
  ]
when "centos", "redhat"
  node[:app][:user] = "apache"
  node[:app][:group] = "apache"
  node[:app][:packages] = [
    "php53u",
    "php53u-pear",
    "php53u-zts"
  ]
end

rightscale_marker :end
