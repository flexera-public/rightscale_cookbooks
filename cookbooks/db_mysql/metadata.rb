maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Provides the MySQL implementation of the 'db' resource to" +
                 " install and manage MySQL database stand-alone servers and clients."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "db"
depends "block_device"
depends "sys_dns"
depends "rightscale"

recipe "db_mysql::setup_server_5_1",
  "Sets the DB MySQL provider. Sets version 5.1 and node variables specific" +
  " to MySQL 5.1."
recipe "db_mysql::setup_server_5_5",
  "Sets the DB MySQL provider. Sets version 5.5 and node variables specific" +
  " to MySQL 5.5."

attribute "db_mysql",
  :display_name => "General Database Options",
  :type => "hash"

# == Default server attributes
#
attribute "db_mysql/server_usage",
  :display_name => "Server Usage",
  :description =>
    "When set to 'dedicated' all server resources are allocated to MySQL." +
    " When set to 'shared' less resources are allocated for MySQL" +
    " so that it can be run concurrently with other" +
    " apps like Apache and Rails for example. Example: shared",
  :choice => ["shared", "dedicated"],
  :required => "optional",
  :default => "shared",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/log_bin",
  :display_name => "MySQL Binlog Destination",
  :description =>
    "Defines the filename and location of your MySQL stored binlog files." +
    " Sets the 'log-bin' variable in the MySQL config file." +
    " Example: /mnt/mysql-binlogs/mysql-bin",
  :required => "optional",
  :default => "/mnt/ephemeral/mysql-binlogs/mysql-bin",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/binlog_format",
  :display_name => "MySQL Binlog Format",
  :description =>
    "Defines the format of your MySQL stored binlog files." +
    " Sets the 'binlog_format' option in the MySQL config file." +
    " Accepted options: STATEMENT, ROW, and MIXED. Example: MIXED",
  :required => "optional",
  :choice => ["STATEMENT", "ROW", "MIXED"],
  :default => "MIXED",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/tmpdir",
  :display_name => "MySQL Temp Directory Destination",
  :description =>
    "Defines the location of your MySQL temp directory." +
    " Sets the 'tmpdir' variable in the MySQL config file. Example: /tmp",
  :required => "optional",
  :default => "/mnt/ephemeral/mysqltmp",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/init_timeout",
  :display_name => "MySQL Init Timeout",
  :description =>
    "Defines timeout to wait for a MySQL socket connection. Default: 600",
  :required => "optional",
  :default => "600",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/expire_logs_days",
  :display_name => "MySQL Expire Logs Days",
  :description =>
    "Defines number of days to wait until the log expires. Default: 2",
  :required => "optional",
  :default => "2",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/enable_mysql_upgrade",
  :display_name => "Enable mysql_upgrade",
  :description =>
    "Run mysql_upgrade if a restore from an older version of MySQL" +
    " is detected. Default: false",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "false",
  :recipes => ["db_mysql::setup_server_5_5"]

attribute "db_mysql/compressed_protocol",
  :display_name => "Compression of the slave/master protocol",
  :description =>
    "Use compression of the slave/master protocol if both the slave and the" +
    " master support it. Default: disabled",
  :required => "optional",
  :choice => ["enabled", "disabled"],
  :default => "disabled",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/ssl/ca_certificate",
  :display_name => "CA SSL Certificate",
  :description =>
    "The name of your CA SSL Certificate." +
    " This is one of the 5 inputs needed to do secured replication." +
    " Example: cred:CA_CERT. Please DO NOT use this input for LAMP" +
    " ServerTemplates.",
  :required => "optional",
  :default => "",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/ssl/master_certificate",
  :display_name => "Master SSL Certificate",
  :description =>
    "The name of your Master SSL Certificate." +
    " This is one of the 5 inputs needed to do secured replication." +
    " Example: cred:MASTER_CERT. Please DO NOT use this input for LAMP" +
    " ServerTemplates.",
  :required => "optional",
  :default => "",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/ssl/master_key",
  :display_name => "Master SSL Key",
  :description =>
    "The name of your Master SSL Key." +
    " This is one of the 5 inputs needed to do secured replication." +
    " Example: cred:MASTER_KEY. Please DO NOT use this input for LAMP" +
    " ServerTemplates.",
  :required => "optional",
  :default => "",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/ssl/slave_certificate",
  :display_name => "Slave SSL Certificate",
  :description =>
    "The name of your Slave SSL Certificate." +
    " This is one of the 5 inputs needed to do secured replication." +
    " Example: cred:SLAVE_CERT. Please DO NOT use this input for LAMP" +
    " ServerTemplates.",
  :required => "optional",
  :default => "",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]

attribute "db_mysql/ssl/slave_key",
  :display_name => "Slave SSL Key",
  :description =>
    "The name of your Slave SSL Key." +
    " This is one of the 5 inputs needed to do secured replication." +
    " Example: cred:SLAVE_KEY. Please DO NOT use this input for LAMP" +
    " ServerTemplates.",
  :required => "optional",
  :default => "",
  :recipes => [
    "db_mysql::setup_server_5_1",
    "db_mysql::setup_server_5_5"
  ]
