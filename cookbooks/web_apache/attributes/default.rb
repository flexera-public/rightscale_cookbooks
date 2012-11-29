#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# Recommended attributes

# Admin email
set_unless[:apache][:contact] = "root@localhost"

# Optional attributes

# Turning off Keepalive to prevent conflicting HAproxy
set_unless[:apache][:keepalive] = "Off" 

# Turn on generation of "full" apache status
set_unless[:apache][:extended_status] = "On"

# worker = multithreaded (when you need a great deal of scalability)
# prefork = single-threaded (when you need stability or compatibility with older software)
# for more info please visit: http://httpd.apache.org/docs/2.0/en/mpm.html
set_unless[:apache][:mpm] = "prefork"

# Security: Configuring Server Signature
set_unless[:apache][:serversignature] = "Off "

# Calculated attributes

# DISTRO specific config dir
case platform
when "ubuntu"
  set[:apache][:config_subdir] = "apache2"
when "centos", "redhat"
  set[:apache][:config_subdir] = "httpd"
end

# Disabling ssl by default
set_unless[:web_apache][:ssl_enable] = false
set_unless[:web_apache][:ssl_certificate] = nil
set_unless[:web_apache][:ssl_certificate_chain] = nil
set_unless[:web_apache][:ssl_key] = nil
set_unless[:web_apache][:ssl_passphrase] = nil

# Apache document root
set[:web_apache][:docroot] = "/home/webapp/#{web_apache[:application_name]}"

# Default servername for web_apache vhost file
set[:web_apache][:server_name] = "localhost"

# Maintenance mode attributes
set[:web_apache][:maintenance_file] = "/home/webapp/system/maintenance.html"

# Allow override default value
set_unless[:web_apache][:allow_override] = "None"
