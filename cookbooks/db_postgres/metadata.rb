name             "db_postgres"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Provides the PostgreSQL implementation of the 'db' resource" +
                 " to install and manage PostgreSQL database stand-alone" +
                 " servers and clients."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.1"

supports "centos"
supports "redhat"

depends "sys_dns"
depends "db"
depends "rightscale"
depends "block_device"

recipe "db_postgres::setup_server_9_1",
  "Sets the DB PostgreSQL provider. Sets version 9.1 and node variables" +
  " specific to PostgreSQL 9.1."

recipe "db_postgres::do_set_slave_sync_mode",
  "Sets master-slave replication mode based on 'db_postgres/sync_mode' input."

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
  :choice => ["shared", "dedicated"],
  :default => "dedicated",
  :required => "optional",
  :recipes => ["db_postgres::setup_server_9_1"]

attribute "db_postgres/sync_mode",
  :display_name => "Streaming replication mode",
  :description =>
    "Defines master-slave replication mode. Default: async",
  :choice => ["async", "sync"],
  :default => "async",
  :required => "optional",
  :recipes => [
    "db_postgres::setup_server_9_1",
    "db_postgres::do_set_slave_sync_mode"
  ]
