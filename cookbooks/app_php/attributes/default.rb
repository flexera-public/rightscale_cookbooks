#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# List of additional php modules
set_unless[:app_php][:modules_list] = []

# Calculated attributes
# Defining apache user, module dependencies, and database adapter parameters depending on platform.
case platform
when "ubuntu"
  set[:app_php][:module_dependencies] = [ "proxy_http", "php5" ]
when "centos", "redhat"
  set[:app_php][:module_dependencies] = [ "proxy", "proxy_http" ]
end

