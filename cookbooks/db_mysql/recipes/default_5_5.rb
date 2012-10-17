#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin
version="5.5"
node[:db][:version] = version
node[:db][:provider] = "db_mysql"

log "  Setting DB MySQL version to #{version}"

# Set MySQL 5.5 specific node variables in this recipe.
#
node[:db][:socket] = value_for_platform(
  "ubuntu"  => {
    "default" => "/var/run/mysqld/mysqld.sock"
  },
  "default" => "/var/lib/mysql/mysql.sock"
)

# http://dev.mysql.com/doc/refman/5.5/en/linux-installation-native.html
# For Red Hat and similar distributions, the MySQL distribution is divided into a
# number of separate packages, mysql for the client tools, mysql-server for the
# server and associated tools, and mysql-libs for the libraries.

node[:db_mysql][:service_name] = value_for_platform(
  "ubuntu" => {
    "10.04" => "",
    "default" => "mysql"
  },
  "default" => "mysqld"
)

node[:db_mysql][:server_packages_uninstall] = []

node[:db_mysql][:server_packages_install] = value_for_platform(
  "ubuntu" => {
    "10.04" => [],
    "default" => [ "mysql-server-5.5" ]
  },
  "default" => [ "mysql55-server" ]
)

node[:db][:init_timeout]= node[:db_mysql][:init_timeout]

# Mysql specific commands for db_sys_info.log file
node[:db][:info_file_options] = ["mysql -V", "cat /etc/mysql/conf.d/my.cnf"]
node[:db][:info_file_location] = "/etc/mysql"

log "  Using MySQL service name: #{node[:db_mysql][:service_name]}"

rightscale_marker :end
