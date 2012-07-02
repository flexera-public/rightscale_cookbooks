#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Optional attributes
# By default php uses MySQL as the DB adapter
set_unless[:app][:db_adapter] = "mysql"
# List of additional php modules
set_unless[:app_php][:modules_list] = []

# Calculated attributes
# Defining apache user, module dependencies, and database adapter parameters depending on platform.
case platform
when "ubuntu", "debian"
  set[:app][:module_dependencies] = [ "proxy_http", "php5" ]
  set_unless[:app_php][:app_user] = "www-data"
when "centos", "fedora", "suse", "redhat"
  set[:app][:module_dependencies] = [ "proxy", "proxy_http" ]
  set_unless[:app_php][:app_user] = "apache"
end

