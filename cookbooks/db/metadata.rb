maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "This cookbook provides a set of database recipes used by" +
                 " the RightScale Database Manager ServerTemplates. This" +
                 " cookbook does not contain a specific database implementation," +
                 " but generic recipes that use the Lightweight Resource" +
                 " Provider (LWRP) interface."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "block_device"
depends "sys_firewall"
depends "db_mysql"
depends "db_postgres"

recipe "db::default",
  "Selects and installs database client. It also sets up the provider" +
  " and version for 'db' resource."

recipe "db::install_server",
  "Installs and sets up the packages that are required for database servers." +
  " Adds the database:active=true tag to your server, which identifies" +
  " it as a database server. The tag is used by application servers to" +
  " identify active databases."

recipe "db::setup_monitoring",
  "Installs the collectd plugin for database monitoring support, which is" +
  " required to enable monitoring and alerting functionality for your servers."

# == Common Database Recipes
#
recipe "db::do_primary_backup",
  :description =>
    "Creates a primary backup of the database using persistent storage in" +
    "the current cloud. Backup type depends on cloud and hypervisor type." +
    " For clouds with volume snapshots support available, volume backup will" +
    " be used only if hypervisor is different than KVM. For the clouds" +
    " without volume snapshots support and for KVM based instances" +
    " backups are uploaded to ROS container.",
  :thread => 'db_backup'

recipe "db::do_primary_restore",
  "Restores the database from the most recently completed primary backup" +
  " available in persistent storage of the current cloud."

recipe "db::do_primary_backup_schedule_enable",
  "Enables db::do_primary_backup to be run periodically."

recipe "db::do_primary_backup_schedule_disable",
  "Disables db::do_primary_backup from being run periodically."

recipe "db::setup_privileges_admin",
  "Adds the username and password for 'superuser' privileges."

recipe "db::setup_privileges_application",
  "Adds the username and password for application privileges."

recipe "db::do_secondary_backup",
  :description =>
    "Creates a backup of the database and uploads it to a secondary cloud" +
    " storage location, which can be used to migrate your database to" +
    " a different cloud. For example, you can save a secondary backup" +
    " to an Amazon S3 bucket or a Rackspace Cloud Files container.",
  :thread => 'db_backup'

recipe "db::do_secondary_restore",
  "Restores the database from the most recently completed backup available" +
  " in a secondary location."

recipe "db::do_force_reset",
  "Resets the database back to a pristine state." +
  " WARNING: Execution of this script will delete any data in your database!"

recipe "db::do_dump_export",
  "Creates a dump file and uploads it to a remote object storage" +
  " (e.g., Amazon S3, Google Cloud Storage, Azure, Softlayer" +
  " or Rackspace Cloud Files)."

recipe "db::do_dump_import",
  "Retrieves a dump file from remote object storage" +
  " (e.g., Amazon S3 Google Cloud Storage, Azure, Softlayer or" +
  " Rackspace Cloud Files) and imports it to the database server."

recipe "db::do_dump_schedule_enable",
  "Schedules the daily run of do_dump_export."

recipe "db::do_dump_schedule_disable",
  "Disables the daily run of do_dump_export."

# == Database Firewall Recipes
#
recipe "db::do_appservers_allow",
  "Allows connections from all application servers in the deployment" +
  " that are tagged with appserver:active=true tag." +
  " This script should be run on a database server so that" +
  " it will accept connections from related application servers."

recipe "db::do_appservers_deny",
  "Denies connections from all application servers in the deployment" +
  " that are tagged with appserver:active=true tag." +
  " This script can be run on a database server to deny connections from all" +
  " application servers in the deployment."

recipe "db::request_appserver_allow",
  "Sends a request to allow connections from the caller's private IP address" +
  " to all database servers in the deployment that are tagged with" +
  " the database:active=true tag. This should be run on an application server" +
  " before attempting a database connection."

recipe "db::request_appserver_deny",
  "Sends a request to deny connections from the caller's private IP address" +
  " to all database servers in the deployment that are tagged with the" +
  " database:active=true tag." +
  " This should be run on an application server upon decommissioning."

# == Master/Slave Recipes
#
recipe "db::do_init_and_become_master",
  "Initializes the database and tags it as the master database server." +
  " Sets DNS. Starts a fresh backup from this master."

recipe "db::do_primary_restore_and_become_master",
  "Restores the database and tags it as the master database server." +
  " Sets DNS. Starts a fresh backup from this master."

recipe "db::do_secondary_restore_and_become_master",
  "Restores the database from a secondary backup location" +
  " and tags it as the master database server. Sets DNS." +
  " Starts a fresh backup from this master."

recipe "db::do_primary_init_slave",
  "Initializes the slave server from the primary backup location." +
  " Authentication information provided by inputs is ignored for slave servers."

recipe "db::do_secondary_init_slave",
  "Initializes the slave server from the secondary backup location." +
  " Authentication information provided by inputs is ignored for slave servers."

recipe "db::do_init_slave_at_boot",
  "Initializes the slave server at boot."

recipe "db::do_set_dns_slave",
  "Sets the slave DNS record to the network interface IP."

recipe "db::do_promote_to_master",
  "Promotes a replicating slave to master."

recipe "db::setup_replication_privileges",
  "Sets up privileges for replication slave servers."

recipe "db::request_master_allow",
  "Sends a request to the master database server tagged with" +
  " rs_dbrepl:master_instance_uuid=<master_instance_uuid>" +
  " to allow connections from the server's private IP address." +
  " This script should be run on a slave before it sets up replication."

recipe "db::request_master_deny",
  "Sends a request to the master database server tagged with" +
  " rs_dbrepl:master_instance_uuid=<master_instance_uuid>" +
  " to deny connections from the server's private IP address." +
  " This script should be run on a slave when it stops replicating."

recipe "db::handle_demote_master",
  "Remote recipe executed by do_promote_to_master. DO NOT RUN."

recipe "db::do_delete_volumes_and_terminate_server",
  "Deletes any currently attached volumes from the instance" +
  " and then terminates the machine."

# == Common Database Attributes
#
attribute "db",
  :display_name => "General Database Options",
  :type => "hash"

attribute "db/dns/master/fqdn",
  :display_name => "Database Master FQDN",
  :description =>
    "The fully qualified domain name for the master database server." +
    " Example: db-master.example.com",
  :required => "required",
  :recipes => ["db::default", "db::install_server"]

attribute "db/dns/master/id",
  :display_name => "Database Master DNS Record ID",
  :description =>
    "The unique identifier that is associated with the DNS A record" +
    " of the master database server.The unique identifier is assigned by" +
    " the DNS provider when you create a dynamic DNS A record." +
    " This ID is used to update the associated A record with the private" +
    " IP address of the master server when this recipe is run." +
    " If you are using DNS Made Easy as your DNS provider, a 7-digit number" +
    " is used (e.g., 4403234).Example:4403234",
  :required => "required",
  :recipes => [
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore_and_become_master",
    "db::do_init_and_become_master",
    "db::do_promote_to_master"
  ]

attribute "db/dns/slave/fqdn",
  :display_name => "Database Slave FQDN",
  :description =>
    "The fully qualified domain name for a slave database server." +
    " Example: db-slave.example.com",
  :required => "optional",
  :recipes => ["db::do_set_dns_slave"]

attribute "db/dns/slave/id",
  :display_name => "Database Slave DNS Record ID",
  :description =>
    "The unique identifier that is associated with the DNS A record of" +
    " a slave server. The unique identifier is assigned by the DNS provider" +
    " when you create a dynamic DNS A record." +
    " This ID is used to update the associated A record with" +
    " the private IP address of a slave server when this recipe is run." +
    " If you are using DNS Made Easy as your DNS provider," +
    " a 7-digit number is used (e.g., 4403234). Example:4403234",
  :required => "required",
  :recipes => ["db::do_set_dns_slave"]

attribute "db/admin/user",
  :display_name => "Database Admin Username",
  :description =>
    "The username of the database user with 'admin' privileges." +
    " Example: cred:DBADMIN_USER.",
  :required => "required",
  :recipes => [
    "db::install_server",
    "db::setup_privileges_admin",
    "db::do_primary_restore",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_restore_and_become_master"
  ]

attribute "db/admin/password",
  :display_name => "Database Admin Password",
  :description =>
    "The password of the database user with 'admin' privileges." +
    " Example: cred:DBADMIN_PASSWORD.",
  :required => "required",
  :recipes => [
    "db::install_server",
    "db::setup_privileges_admin",
    "db::do_primary_restore",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_restore_and_become_master"
  ]

attribute "db/replication/user",
  :display_name => "Database Replication Username",
  :description =>
    "The username of the database user that has 'replication' privileges." +
    " Example: cred:DBREPLICATION_USER.",
  :required => "required",
  :recipes => [
    "db::setup_replication_privileges",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore_and_become_master",
    "db::do_init_and_become_master",
    "db::do_promote_to_master",
    "db::do_primary_init_slave",
    "db::do_secondary_init_slave",
    "db::do_init_slave_at_boot"
  ]

attribute "db/replication/password",
  :display_name => "Database Replication Password",
  :description =>
    "The password of the database user that has 'replication' privileges." +
    " Example: cred:DBREPLICATION_PASSWORD.",
  :required => "required",
  :recipes => [
    "db::setup_replication_privileges",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore_and_become_master",
    "db::do_init_and_become_master",
    "db::do_promote_to_master",
    "db::do_primary_init_slave",
    "db::do_secondary_init_slave",
    "db::do_init_slave_at_boot"
  ]

attribute "db/replication/network_interface",
  :display_name => "Database Replication Network Interface",
  :description =>
    "The network interface used for replication. WARNING: when selecting" +
    " 'public' we highly recommend enabling SSL encryption, otherwise data" +
    " could travel over insecure connections. Make sure you understand what" +
    " you are doing before changing this value. Default: private",
  :required => "optional",
  :choice => ["private", "public", "vpn"],
  :default => "private",
  :recipes => [
    "db::install_server",
    "db::do_promote_to_master",
    "db::request_master_allow",
    "db::request_master_deny",
    "db::do_set_dns_slave"
  ]

attribute "db/application/user",
  :display_name => "Database Application Username",
  :description =>
    "The username of the database user that has 'user' privileges." +
    " Example: cred:DBAPPLICATION_USER.",
  :required => "required",
  :recipes => [
    "db::default",
    "db::setup_privileges_application",
    "db::install_server",
    "db::do_primary_restore",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_restore_and_become_master"
  ]

attribute "db/application/password",
  :display_name => "Database Application Password",
  :description =>
    "The password of the database user that has 'user' privileges." +
    " Example: cred:DBAPPLICATION_PASSWORD.",
  :required => "required",
  :recipes => [
    "db::default",
    "db::setup_privileges_application",
    "db::install_server",
    "db::do_primary_restore",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_restore_and_become_master"
  ]

attribute "db/init_slave_at_boot",
  :display_name => "Init Slave at Boot",
  :description =>
    "Set to 'True' to have the instance initialize the database server" +
    " as a slave on boot. Set to 'False' if there is no master database" +
    " server running. Example: false",
  :default => "false",
  :choice => ["true", "false"],
  :recipes => ["db::do_init_slave_at_boot"]

attribute "db/dns/ttl",
  :display_name => "Database DNS TTL Limit",
  :description =>
    "The upper limit for the TTL of the master DB DNS record in seconds." +
    " This value should be kept low in the event of Master DB failure" +
    " so that the DNS record updates in a timely manner. When installing" +
    " the DB server, this value is checked in the DNS records." +
    " Input should be set for 300 when using CloudDNS. Example: 60",
  :required => "optional",
  :default => "60",
  :choice => ["60", "300"],
  :recipes => ["db::install_server"]

attribute "db/provider_type",
  :display_name => "Database Provider type",
  :description =>
    "Database provider type to use on client side. This must be a string" +
    " containing the provider cookbook name and (optionally) the version" +
    " of the database." +
    " Example: db_mydatabase_1.0, db_mysql_5.1, db_mysql_5.5, db_postgres_9.1",
  :required => "required",
  :choice => ["db_mysql_5.1", "db_mysql_5.5", "db_postgres_9.1"],
  :recipes => ["db::default"]

# == Backup/Restore
#
attribute "db/backup/lineage",
  :display_name => "Database Backup Lineage",
  :description =>
    "The prefix that will be used to name/locate the backup of a particular" +
    " database.Note: For servers running on Rackspace, this value" +
    " also indicates the Cloud Files container to use for storing" +
    " primary backups.If a Cloud Files container with this name" +
    " does not already exist,the setup process creates one." +
    " Example: text:prod_db_lineage",
  :required => "required",
  :recipes => [
    "db::do_primary_init_slave",
    "db::do_secondary_init_slave",
    "db::do_init_slave_at_boot",
    "db::do_promote_to_master",
    "db::do_primary_restore_and_become_master",
    "db::do_secondary_restore_and_become_master",
    "db::do_init_and_become_master",
    "db::do_primary_backup",
    "db::do_primary_restore",
    "db::do_primary_backup_schedule_enable",
    "db::do_primary_backup_schedule_disable",
    "db::do_force_reset",
    "db::do_secondary_backup",
    "db::do_secondary_restore"
  ]

attribute "db/backup/lineage_override",
  :display_name => "Database Restore Lineage Override",
  :description =>
    "If defined, this will override the input defined for 'Backup Lineage'" +
    " (db/backup/lineage) so that you can restore the database from" +
    " another backup that has as a different lineage name." +
    " The most recently completed snapshots will be used unless a specific" +
    " timestamp value is specified for 'Restore Timestamp Override'" +
    " (db/backup/timestamp_override). Although this input allows you to" +
    " restore from a different set of snapshots, subsequent backups will" +
    " use 'Backup Lineage' to name the snapshots." +
    " Be sure to remove the 'Backup Lineage Override' input after" +
    " the new master is operational. Example: text:new_db_lineage",
  :required => "optional",
  :recipes => [
    "db::do_init_slave_at_boot",
    "db::do_primary_restore_and_become_master",
    "db::do_primary_restore",
    "db::do_primary_init_slave",
    "db::do_secondary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_init_slave"
  ]

attribute "db/backup/timestamp_override",
  :display_name => "Database Restore Timestamp Override",
  :description =>
    "An optional variable to restore a database backup with a specific" +
    " timestamp rather than the most recent backup in the lineage." +
    " You must specify a string that matches the timestamp tag" +
    " on the volume snapshot. You will need to specify the timestamp" +
    " that is defined by the snapshot's tag (not the name)." +
    " For example, if the snapshot's tag is 'rs_backup:timestamp=1303613371'" +
    " you would specify '1303613371' for this input. Example: 1303613371",
  :required => "optional",
  :recipes => [
    "db::do_primary_restore_and_become_master",
    "db::do_primary_restore",
    "db::do_primary_init_slave",
    "db::do_secondary_restore_and_become_master",
    "db::do_secondary_restore",
    "db::do_secondary_init_slave"
  ]

attribute "db/backup/primary/master/cron/hour",
  :display_name => "Master Backup Cron Hour",
  :description =>
    "Defines the hour of the day when the primary backup will be taken of" +
    " the master database. Backups of the master are taken daily." +
    " By default, an hour will be randomly chosen at launch time." +
    " Otherwise, the time of the backup is defined by 'Master Backup" +
    " Cron Hour' and 'Master Backup Cron Minute'. However, if you specify" +
    " a value in this input (e.g., 23 for 11:00 PM)," +
    " then backups will occur once per day at the specified hour," +
    " rather than hourly. Uses standard crontab format. Example: 23 ",
  :required => "optional",
  :recipes => ["db::do_primary_backup_schedule_enable"]

attribute "db/backup/primary/slave/cron/hour",
  :display_name => "Slave Backup Cron Hour",
  :description =>
    "By default, primary backups of the slave database are taken hourly." +
    " However, if you specify a value in this input" +
    " (e.g., 23 for 11:00 PM), then backups will occur once per day" +
    " at the specified hour, rather than hourly. Example: 23.",
  :required => "optional",
  :recipes => ["db::do_primary_backup_schedule_enable"]

attribute "db/backup/primary/master/cron/minute",
  :display_name => "Master Backup Cron Minute",
  :description =>
    "Defines the minute of the hour when the backup of the master database" +
    " will be taken. Backups of the master are taken daily." +
    " By default, a minute will be randomly chosen at launch time." +
    " Otherwise, the time of the backup is defined" +
    " by 'Master Backup Cron Hour' and 'Master Backup Cron Minute'." +
    " Uses standard crontab format. Example: 30",
  :required => "optional",
  :recipes => ["db::do_primary_backup_schedule_enable"]

attribute "db/backup/primary/slave/cron/minute",
  :display_name => "Slave Backup Cron Minute",
  :description =>
    "Defines the minute of the hour when the backup" +
    " EBS snapshot will be taken of the slave database." +
    " Backups of the slave are taken hourly." +
    " By default, a minute will be randomly chosen at launch time." +
    " Uses standard crontab format (e.g., 30 for minute 30 of the hour)." +
    " Example 30",
  :required => "optional",
  :recipes => ["db::do_primary_backup_schedule_enable"]

# == Import/export attributes
#
attribute "db/dump",
  :display_name => "Import/export settings for database dump file management.",
  :type => "hash"

attribute "db/dump/storage_account_provider",
  :display_name => "Dump Storage Account Provider",
  :description =>
    "Location where the dump file will be saved." +
    " Used by dump recipes to back up to remote object storage" +
    " (complete list of supported storage locations is in input dropdown)." +
    " Example: s3",
  :required => "required",
  :choice => [
    "s3",
    "cloudfiles",
    "cloudfilesuk",
    "google",
    "azure",
    "swift",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/storage_account_id",
  :display_name => "Dump Storage Account ID",
  :description =>
    "In order to write the dump file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your Amazon access key ID" +
    " (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your" +
    " Rackspace login username (e.g., cred:RACKSPACE_USERNAME)." +
    " For OpenStack Swift the format is: 'tenantID:username'." +
    " Example: cred:AWS_ACCESS_KEY_ID",
  :required => "required",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/storage_account_secret",
  :display_name => "Dump Storage Account Secret",
  :description =>
    "In order to write the dump file to the specified cloud storage location," +
    " you need to provide cloud authentication credentials." +
    " For Amazon S3, use your AWS secret access key" +
    " (e.g., cred:AWS_SECRET_ACCESS_KEY)." +
    " For Rackspace Cloud Files, use your Rackspace account API key" +
    " (e.g., cred:RACKSPACE_AUTH_KEY). Example: cred:AWS_SECRET_ACCESS_KEY",
  :required => "required",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/storage_account_endpoint",
  :display_name => "Dump Storage Endpoint URL",
  :description =>
    "The endpoint URL for the storage cloud. This is used to override the" +
    " default endpoint or for generic storage clouds such as Swift." +
    " Example: http://endpoint_ip:5000/v2.0/tokens",
  :required => "optional",
  :default => "",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/container",
  :display_name => "Dump Container",
  :description =>
    "The cloud storage location where the dump file will be saved to" +
    " or restored from. For Amazon S3, use the bucket name." +
    " For Rackspace Cloud Files, use the container name." +
    " Example: db_dump_bucket",
  :required => "required",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/prefix",
  :display_name => "Dump Prefix",
  :description =>
    "The prefix that will be used to name/locate the backup" +
    " of a particular database dump. Defines the prefix of the dump file name" +
    " that will be used to name the backup database dump file," +
    " along with a timestamp. Example: prod_db_backup",
  :required => "required",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/dump/database_name",
  :display_name => "Database Schema Name",
  :description =>
    "Enter the name of the database name/schema to create/restore a dump" +
    " from/for. Example: mydbschema",
  :required => "required",
  :recipes => [
    "db::do_dump_import",
    "db::do_dump_export",
    "db::do_dump_schedule_enable"
  ]

attribute "db/terminate_safety",
  :display_name => "Terminate Safety",
  :description =>
    "Prevents the accidental running of the 'db::do_teminate_server' recipe." +
    " This recipe will only run if this input variable is overridden" +
    " and set to \"off\". Example: text:off",
  :type => "string",
  :choice =>
    ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default =>
    "Override the dropdown and set to \"off\" to really run this recipe",
  :required => "optional",
  :recipes => ["db::do_delete_volumes_and_terminate_server"]

attribute "db/force_safety",
  :display_name => "Force Reset Safety",
  :description =>
    "Prevents the accidental running of the db::do_force_reset recipe." +
    " This recipe will only run if the input variable is overridden" +
    " and set to \"off\". Example: text:off",
  :type => "string",
  :choice =>
    ["Override the dropdown and set to \"off\" to really run this recipe"],
  :default =>
    "Override the dropdown and set to \"off\" to really run this recipe",
  :required => "optional",
  :recipes => ["db::do_force_reset"]

attribute "db/force_promote",
  :display_name => "Force Promote to Master",
  :description =>
    "If true, when promoting a slave to master, ignores making checks and" +
    " changes to any current master. WARNING: setting this will promote a" +
    " slave to a master with no replication until a new slave is brought up." +
    " Make sure you understand what you are doing before changing this value." +
    " Default: false",
  :required => "optional",
  :default => "false",
  :choice => ["true", "false"],
  :recipes => ["db::do_promote_to_master"]
