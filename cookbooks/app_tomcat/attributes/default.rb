#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# By default tomcat uses MySQL as the DB adapter
set_unless[:app][:db_adapter] = "mysql"
# Recommended attributes
set_unless[:app_tomcat][:code][:root_war] = ""
# Java heap tuning attributes. For more info see http://www.tomcatexpert.com/blog/2011/11/22/performance-tuning-jvm-running-tomcat
# Defines the initial value of the permanent generation space size
set_unless[:app_tomcat][:java][:permsize] = "256m"
# Defines the maximum value of the permanent generation space size
set_unless[:app_tomcat][:java][:maxpermsize] = "256m"
# Defines the initial size of new space generation
set_unless[:app_tomcat][:java][:newsize] = "256m"
# Defines the maximum size of new space generation
set_unless[:app_tomcat][:java][:maxnewsize] = "256m"
# Defines the maximum size of the heap used by the JVM
set_unless[:app_tomcat][:java][:xmx] = "512m"
# Defines the initial size of the heap used by the JVM
set_unless[:app_tomcat][:java][:xms] = "512m"

# List of required apache modules
set[:app_tomcat][:module_dependencies] = [ "proxy", "proxy_http", "deflate", "rewrite" ]

# Calculated attributes
# Defining apache user, java alternatives and database adapter parameters depending on platform.
case node[:platform]
when "ubuntu", "debian"
  set[:app_tomcat][:app_user] = "tomcat6"
  set[:app_tomcat][:alternatives_cmd] = "update-alternatives --auto java"
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  set[:app_tomcat][:app_user] = "tomcat"
  set[:app_tomcat][:alternatives_cmd] = "alternatives --auto java"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end
