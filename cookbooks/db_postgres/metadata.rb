maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/configures a PostgreSQL database client and server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "sys_dns"
depends "db"
depends "rightscale"
depends "block_device"

recipe "db_postgres::setup_server_9_1",
  "Sets the DB PostgreSQL provider. Sets version 9.1 and node variables" +
  " specific to PostgreSQL 9.1."

recipe "db_postgres::do_set_slave_sync_mode",
  "Sets master to do sync-based replication with slaves."

recipe "db_postgres::do_set_slave_async_mode",
  "Sets master to do async-based replication with slaves."

recipe "db_postgres::do_show_slave_sync_mode",
  "Shows the sync mode used for replication."

attribute "db_postgres",
  :display_name => "General Database Options",
  :type => "hash"

attribute "db_postgres/server_usage",
  :display_name => "Server Usage",
  :description =>
    "Use 'dedicated' if the PostgreSQL config file allocates all existing" +
    " resources of the machine. Use 'shared' if the PostgreSQL config file" +
    " is configured to use less resources so that it can be run concurrently" +
    " with other apps like Apache and Rails for example." +
    " Example: dedicated",
  :recipes => ["db_postgres::setup_server_9_1"],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"
