#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Setup default values for database resource

rightscale_marker :begin

version = "9.1"
node[:db][:version] = version
node[:db][:provider] = "db_postgres"

log "  Setting DB PostgreSQL version to #{version}"

# Set PostgreSQL 9.1 specific node variables in this recipe.
#

node[:db_postgres][:server_packages_install] = value_for_platform(
  ["centos", "redhat"] => {
    "default" => [
      "postgresql91-libs",
      "postgresql91",
      "postgresql91-devel",
      "postgresql91-server",
      "postgresql91-contrib"
    ]
  },
  "default" => []
)

node[:db][:init_timeout]= "60"

# PostgreSQL specific commands for db_sys_info.log file
node[:db][:info_file_options] = [
  "pg_config --version",
  "cat #{node[:db_postgres][:datadir]}/postgresql.conf"
]
node[:db][:info_file_location] = node[:db_postgres][:datadir]

rightscale_marker :end
