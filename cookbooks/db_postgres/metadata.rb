maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/configures a PostgreSQL database server with automated backups."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.0.0"

# supports "centos", "~> 5.8", "~> 6.2"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "sys_dns"
depends "db"
depends "rightscale"
depends "block_device"

recipe  "db_postgres::default", "Set the DB PostgreSQL provider. Sets version and node variables specific to the chosen PostgresSQL version."
recipe  "db_postgres::default_9_1", "Set the DB PostgresSQL provider. Sets version 9.1 and node variables specific to PostgresSQL 9.1."
recipe  "db_postgres::do_set_slave_sync_mode", "Set master to do sync based replication with slave. PostgreSQL streaming replication is asynchronous by default. If the primary server crashes then some transactions that were committed may not have been replicated to the standby server, causing data loss. The amount of data loss is proportional to the replication delay at the time of failover.
Synchronous replication offers the ability to confirm that all changes made by a transaction have been transferred to one synchronous standby server. This extends the standard level of durability offered by a transaction commit. This level of protection is referred to as 2-safe replication in computer science theory.
Ref: http://www.postgresql.org/docs/9.1/static/warm-standby.html#SYNCHRONOUS-REPLICATION"
recipe  "db_postgres::do_set_slave_async_mode", "Set master to do a sync based on replication with a slave. For more info refer http://www.postgresql.org/docs/9.1/static/warm-standby.html#SYNCHRONOUS-REPLICATION"
recipe  "db_postgres::do_show_slave_sync_mode", "Show the sync mode for the replication."

attribute "db_postgres",
  :display_name => "General Database Options",
  :type => "hash"
  
# == Default attributes
#
attribute "db_postgres/server_usage",
  :display_name => "Server Usage",
  :description => "Use 'dedicated' if the postgresql config file allocates all existing resources of the machine.  Use 'shared' if the PostgreSQL config file is configured to use less resources so that it can be run concurrently with other apps like Apache and Rails for example.",
  :recipes => [
    "db_postgres::default_9_1"
  ],
  :choice => ["shared", "dedicated"],
  :default => "dedicated"

attribute "db_postgres/database_name",
  :display_name => "Database Name",
  :description => "Enter the name of the PostgreSQL database for setting up postgresql database monitoring. Ex: mydbname",
  :required => true,
  :recipes => [ "db_postgres::default_9_1"]
