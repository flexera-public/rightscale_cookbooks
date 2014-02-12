#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# worker = multithreaded (when you need a great deal of scalability)
# prefork = single-threaded (when you need stability or compatibility with older software)
# for more info please visit: http://httpd.apache.org/docs/2.0/en/mpm.html
default[:web_apache][:mpm] = "prefork"

# Distribution specific config dir
case platform
when "ubuntu"
  set[:web_apache][:config_subdir] = "apache2"
when "centos", "redhat"
  set[:web_apache][:config_subdir] = "httpd"
end

# Optional attributes

# Multi processing module
default[:web_apache][:mpm] = "prefork"
# Disabling ssl by default
default[:web_apache][:ssl_enable] = false
# SSL certificate
default[:web_apache][:ssl_certificate] = ""
# SSL certificate chain
default[:web_apache][:ssl_certificate_chain] = ""
# SSL certificate key
default[:web_apache][:ssl_key] = ""
# SSL passphrase
default[:web_apache][:ssl_passphrase] = ""
# Application name
default[:web_apache][:application_name] = "myapp"
# Allow override default value
default[:web_apache][:allow_override] = "None"

# Apache document root
set[:web_apache][:docroot] = "/home/webapps/#{web_apache[:application_name]}"

# Default servername for web_apache vhost file
set[:web_apache][:server_name] = "localhost"

# Maintenance mode attributes
set[:web_apache][:maintenance_file] = "/home/webapps/system/maintenance.html"
