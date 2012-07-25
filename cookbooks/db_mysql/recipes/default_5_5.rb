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
platform = node[:platform]

# Set MySQL 5.5 specific node variables in this recipe.
#
node[:db][:socket] = value_for_platform(
  "ubuntu"  => "/var/run/mysqld/mysqld.sock",
  "default" => "/var/lib/mysql/mysql.sock"
)

node[:db_mysql][:service_name] = "mysqld"

# http://dev.mysql.com/doc/refman/5.5/en/linux-installation-native.html
# For Red Hat and similar distributions, the MySQL distribution is divided into a
# number of separate packages, mysql for the client tools, mysql-server for the
# server and associated tools, and mysql-libs for the libraries.

# centos 6.2 by default has mysql-libs 5.1 installed as requirement for postfix.
# Will uninstall postfix, install mysql55-lib then reinstall postfix to use new lib.

node[:db_mysql][:client_packages_uninstall] = value_for_platform(
  "centos" => {
    "6.2"     => [ "postfix", "mysql-libs" ],
    "default" => [ ]
  },
  "default"  => [ ]
)

node[:db_mysql][:server_packages_uninstall] = [ ]

node[:db_mysql][:client_packages_install] = value_for_platform(
  "centos" => {
    "6.2" => [
      "mysql55-devel",
      "mysql55-libs",
      "mysql55",
      "postfix"
    ],
    "default" => [
      "mysql55-devel",
      "mysql55-libs",
      "mysql55"
    ]
  },
  ["redhat", "fedora", "suse"] => {
    "default" => [
      "mysql55-devel",
      "mysql55-libs",
      "mysql55"
    ]
  },
  "default"    => [ ]
)

node[:db_mysql][:server_packages_install] = [ "mysql55-server" ]

raise "Platform not supported for MySQL #{version}" if node[:db_mysql][:client_packages_install].empty?

log "  Using MySQL service name: #{node[:db_mysql][:version]}"

rightscale_marker :end
