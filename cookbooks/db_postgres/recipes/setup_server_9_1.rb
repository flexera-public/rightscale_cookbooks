#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Setup default values for database resource

rightscale_marker

node[:db][:version] = "9.1"
node[:db][:provider] = "db_postgres"

log "  Setting DB PostgreSQL version to #{node[:db][:version]}"

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

node[:db_postgres][:service_name] = value_for_platform(
  ["centos", "redhat"] => {
    "default" => "postgresql-9.1"
  }
)

# Platform specific attributes
case node[:platform]
when "centos", "redhat"
  node[:db_postgres][:confdir] = "/var/lib/pgsql/9.1/data"
  node[:db_postgres][:datadir] = "/var/lib/pgsql/9.1/data"
  node[:db_postgres][:backupdir] = "/var/lib/pgsql/9.1/backups"
  node[:db_postgres][:bindir] = "/usr/pgsql-9.1/bin"
else
  raise "Platform '#{node[:platform]}' is not supported by this recipe."
end

node[:db][:init_timeout]= "60"

# PostgreSQL specific commands for db_sys_info.log file
node[:db][:info_file_options] = [
  "pg_config --version",
  "cat #{node[:db_postgres][:datadir]}/postgresql.conf"
]
node[:db][:info_file_location] = node[:db_postgres][:datadir]

# Database client driver used for Jboss and Tomcat application servers.
node[:db][:client][:jar_file] = "postgresql-9.1-901.jdbc4.jar"
