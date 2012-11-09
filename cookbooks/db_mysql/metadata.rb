maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/configures a MySQL database client and server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "db"
depends "block_device"
depends "sys_dns"
depends "rightscale"

recipe  "db_mysql::setup_server_5_1", "Set the DB MySQL provider. Sets version 5.1 and node variables specific to MySQL 5.1."
recipe  "db_mysql::setup_server_5_5", "Set the DB MySQL provider. Sets version 5.5 and node variables specific to MySQL 5.5."

attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"

# == Default server attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description => "When set to 'dedicated' all server resources are allocated to MySQL. When set to 'shared' less resources are allocated for MySQL so that it can be run concurrently with other apps like Apache and Rails for example.  Example: shared",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :choice => ["shared", "dedicated"],
  :required => "optional",
  :default => "shared"

attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description => "Defines the filename and location of your MySQL stored binlog files. Sets the 'log-bin' variable in the MySQL config file. Example: /mnt/mysql-binlogs/mysql-bin",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :required => "optional",
  :default => "/mnt/ephemeral/mysql-binlogs/mysql-bin"

attribute "db_mysql/binlog_format",
  :display_name => "MySQL Binlog Format",
  :description => "Defines the format of your MySQL stored binlog files. Sets the 'binlog_format' option in the MySQL config file. Accepted options: STATEMENT, ROW, and MIXED",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :required => "optional",
  :choice => ["STATEMENT", "ROW", "MIXED"],
  :default => "MIXED"

attribute "db_mysql/tmpdir",
  :display_name => "MySQL Temp Directory Destination",
  :description => "Defines the location of your MySQL temp directory. Sets the 'tmpdir' variable in the MySQL config file. Example: /tmp",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :required => "optional",
  :default => "/mnt/ephemeral/mysqltmp"

attribute "db_mysql/init_timeout",
  :display_name => "MySQL Init Timeout",
  :description => "Defines timeout to wait for a MySQL socket connection. Default: 600",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :required => "optional",
  :default => "600"

attribute "db_mysql/tunable/expire_logs_days",
  :display_name => "MySQL Expire Logs Days",
  :description => "Defines number of days to wait until the log expires. Default: 2",
  :recipes => ["db_mysql::setup_server_5_1", "db_mysql::setup_server_5_5"],
  :required => "optional",
  :default => "2"

