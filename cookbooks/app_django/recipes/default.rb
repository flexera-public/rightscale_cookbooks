#
# Cookbook Name::app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for Django."
node[:app][:provider] = "app_django"

# Ubuntu 12.04 support https://wiki.ubuntu.com/Python
case node[:platform]
when "ubuntu"
  node[:app][:packages] = [
    "libcurl4-openssl-dev",
    "apache2-mpm-prefork",
    "apache2-prefork-dev",
    "libapr1-dev",
    "libcurl4-openssl-dev",
    "python-dev",
    "python-setuptools",
    "libapache2-mod-wsgi",
    "python-simplejson",
    "python-pip"
   ]
  node[:app][:user] = "www-data"
  node[:app][:group] = "www-data"
when "centos", "redhat"
  node[:app][:packages] = [
    "zlib-devel",
    "openssl-devel",
    "readline-devel",
    "curl-devel",
    "openssl-devel",
    "httpd-devel",
    "apr-devel",
    "apr-util-devel",
    "readline-devel",
    "mod_wsgi",
    "python-libs",
    "python-devel",
    "python-setuptools",
    "python-simplejson",
    "python-pip"
   ]
  node[:app][:user] = "apache"
  node[:app][:group] = "apache"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Set debug mode django style (https://docs.djangoproject.com/en/dev/ref/settings/#debug)
node[:app_django][:app][:debug_mode].gsub!(/^./) {|a| a.upcase}

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"

# Django shares the same doc root with the application destination
node[:app][:root] = "#{node[:app][:destination]}"

# We do not care about version number here.
# need only the type of database adaptor
node[:app][:db_adapter] = node[:db][:provider_type].match(/^db_([a-z]+)/)[1]


rightscale_marker :end
