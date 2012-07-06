#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin
version="5.5"
node[:db][:provider] = "db_mysql"

log "  Setting DB MySQL version to #{version}"
node[:db_mysql][:version] = version

# Set MySQL 5.5 specific node variables in this recipe.
#
platform = node[:platform]
case platform
when "redhat","centos","fedora","suse"
  # http://dev.mysql.com/doc/refman/5.5/en/linux-installation-native.html
  # For Red Hat and similar distributions, the MySQL distribution is divided into a 
  # number of separate packages, mysql for the client tools, mysql-server for the 
  # server and associated tools, and mysql-libs for the libraries. 
  node[:db_mysql][:service_name] = "mysqld"
  node[:db_mysql][:client_packages_uninstall] = [ ]
  node[:db_mysql][:server_packages_uninstall] = [ ]
  node[:db_mysql][:client_packages_install] = [ "mysql55-devel", "mysql55-libs", "mysql55" ]
  node[:db_mysql][:server_packages_install] = [ "mysql55-server" ]
  # centos 6.2 by default has mysql-libs 5.1 installed as requirement for postfix
  if platform == "centos" && node[:platform_version] == "6.2"
    node[:db_mysql][:client_packages_uninstall] += [ "postfix", "mysql-libs" ]
    node[:db_mysql][:client_packages_install] += [ "postfix" ]
  end
else
  raise "Unsupported platform #{platform} for MySQL Version #{version}"
end

rightscale_marker :end
