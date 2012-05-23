#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
set_unless[:app_tomcat][:code][:root_war] = ""
set_unless[:app_tomcat][:java][:permsize] = "256m"
set_unless[:app_tomcat][:java][:maxpermsize] = "256m"
set_unless[:app_tomcat][:java][:newsize] = "256m"
set_unless[:app_tomcat][:java][:maxnewsize] = "256m"
set_unless[:app_tomcat][:java][:xmx] = "512m"
set_unless[:app_tomcat][:java][:xms] = "512m"
set_unless[:app_tomcat][:db_adapter] = "mysql"

set[:app_tomcat][:module_dependencies] = [ "proxy", "proxy_http", "deflate", "rewrite"]


# Calculated attributes
case node[:platform]
when "ubuntu", "debian"
  set[:app_tomcat][:app_user] = "tomcat6"
  set[:app_tomcat][:alternatives_cmd] = "update-alternatives  --auto java"
  if app_tomcat[:db_adapter] == "mysql"
    set[:db_mysql][:socket] = "/var/run/mysqld/mysqld.sock"
  elsif app_tomcat[:db_adapter] == "postgresql"
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  set[:app_tomcat][:app_user] = "tomcat"
  set[:app_tomcat][:alternatives_cmd] = "alternatives --auto java"
  if app_tomcat[:db_adapter] == "mysql"
    set[:db_mysql][:socket] = "/var/lib/mysql/mysql.sock"
  elsif app_tomcat[:db_adapter] == "postgresql"
    set[:db_postgres][:socket] = "/var/run/postgresql"
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end
