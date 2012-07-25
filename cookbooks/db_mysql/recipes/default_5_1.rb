#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version="5.1"
node[:db][:provider] = "db_mysql"

log "  Setting DB MySQL version to #{version}"

# Set MySQL 5.1 specific node variables in this recipe.
#
node[:db_mysql][:version] = version

node[:db_mysql][:service_name] = value_for_platform(
  "centos" => {
    "5.8"     => "mysql",
    "default" => "mysqld"
  },
  "default"   => "mysql"
)

node[:db_mysql][:client_packages_uninstall] = [ ]
node[:db_mysql][:server_packages_uninstall] = [ ]

node[:db_mysql][:client_packages_install] = value_for_platform(
  "centos" => {
    "5.8"=> [
      "MySQL-shared-compat",
      "MySQL-devel-community",
      "MySQL-client-community"
    ],
    "default" => [
      "mysql-devel",
      "mysql-libs",
      "mysql"
    ] 
  },
  ["redhat", "fedora", "suse"] => {
    "default" => [
      "MySQL-shared-compat",
      "MySQL-devel-community",
      "MySQL-client-community"
    ]
  },
  ["debian", "ubuntu"] => {
    "10.04" => [ ],
    "default" => [
      "libmysqlclient-dev",
      "mysql-client-5.1"
    ]
  },
  "default" => [ ] 
)

node[:db_mysql][:server_packages_install] = value_for_platform(
  "centos" => {
    "5.8" => [ "MySQL-server-community" ],
    "default" => [ "mysql-server" ]
  },
  ["redhat", "fedora", "suse"] => {
    "default" => [ "MySQL-server-community" ]
  },
  ["debian", "ubuntu"] => {
    "10.04" => [ "mysql-server-5.1" ],
    "default"   => [ ]
  },
  "default" => [ ] 
)

log "  Platform not supported for MySQL #{version}" do
  level :fatal
  only_if { node[:db_mysql][:client_packages_install].empty? }
end

rightscale_marker :end
