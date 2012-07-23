#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Optional attributes
# Application database name
set_unless[:app_php][:db_schema_name] = ""

# List of additional php modules
set_unless[:app_php][:modules_list] = []

# By default php will use MySQL as primary database adapter
set_unless[:app_php][:db_adapter] = "mysql"

# Calculated attributes
# Defining apache user, module dependencies, and database adapter parameters depending on platform.
case platform
when "ubuntu"
  set[:app_php][:module_dependencies] = [ "proxy_http", "php5" ]
  set_unless[:app_php][:app_user] = "www-data"
  if app_php[:db_adapter] == "mysql"
    set[:db][:socket] = "/var/run/mysqld/mysqld.sock"
  elsif app_php[:db_adapter] == "postgresql"
    set[:db][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting"
  end
when "centos", "redhat"
  set[:app_php][:module_dependencies] = [ "proxy", "proxy_http" ]
  set_unless[:app_php][:app_user] = "apache"
  if app_php[:db_adapter] == "mysql"
    set[:db][:socket] = "/var/lib/mysql/mysql.sock"
  elsif app_php[:db_adapter] == "postgresql"
    set[:db][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:app_php][:db_adapter]}, exiting"
  end
end
