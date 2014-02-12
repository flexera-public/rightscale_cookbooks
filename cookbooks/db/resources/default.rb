#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# = Database Attributes
#
# Below are the attributes defined by the database resource interface.
#

# == General options

# Database user
attribute :user, :kind_of => String, :default => "root"

# Password for database user
attribute :password, :kind_of => String, :default => ""

# Database location
attribute :data_dir, :kind_of => String, :default => "/mnt/storage"

# Database driver type. Example: MySQL, PostgreSQL
attribute :driver_type, :kind_of => String

# == Backup/Restore options

# Lineage of the database
attribute :lineage, :kind_of => String

# Override default timestamp when restoring database from backup
attribute :timestamp_override, :kind_of => String, :default => nil

# Attribute to specify whether backup was taken from master database
attribute :from_master, :kind_of => String, :default => nil

# Type of database restore. Example: primary or secondary
attribute :restore_process, :kind_of => Symbol, :default => :primary_restore

# Timeout value for backup actions on database
attribute :timeout, :kind_of => String, :default => "60"

# == Privilege options

# Types of privileges for the database. Example: admininstrator, user
attribute :privilege, :equal_to => ["administrator", "user"], :default => "administrator"

# Username to set privileges on a database
attribute :privilege_username, :kind_of => String

# Password to set privileges on a database
attribute :privilege_password, :kind_of => String

# Database to set privileges
attribute :privilege_database, :kind_of => String, :default => "*.*"

# == Firewall options

# Enable firewall on database server
#
attribute :enable, :equal_to => [true, false], :default => true

# IP Address of the database server
attribute :ip_addr, :kind_of => String

# Machine tags on a database server
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/

# == Import/Export options

# Database dump file name
attribute :dumpfile, :kind_of => String

# Database name
attribute :db_name, :kind_of => String

# Database version
attribute :db_version, :kind_of => String

# = General Database Actions
#
# Below are the actions defined by the database resource interface.
#

# Stops the database service. Calls the correct init.d script for the database
# and platform.
actions :stop

# Starts the database service. Calls the correct init.d script for the database
# and platform.
actions :start

# Logs the status of the database service. Calls the correct init.d script for
# the database and platform and send the output to the Chef log and RightScale
# audit entries.
actions :status

# Locks the database so writes will be blocked. This must insure a consistent
# state while taking a snapshot.
actions :lock

# Unlocks the database so writes can occur. This must be called as soon as
# possible after calling the :lock action  since clients will be blocked
# from writing until unlocked.
actions :unlock

# Wipes the current database into a pristine state. This utility action can be
# useful in development and test environments. Not recommended for production
# use. WARNING: this will delete any data in your database!
actions :reset

# Updates database firewall rules.
actions :firewall_update

# Sends a remote_recipe that requests a database updates it's firewall rules.
actions :firewall_update_request

# Relocates the database data directory. Moves the data directory from the
# default install path to the path specified in name attribute or data_dir
# attribute of the resource. This is used for relocating the data directory to a
# block device that provides snapshot functionality. This action should also
# setup a symlink from the old path to the new location.
actions :move_data_dir

# Generates dump file
actions :generate_dump_file

# Restores database from dump file
actions :restore_from_dump_file

# Verifies the database is in a good state for taking a snapshot. This action is
# used to verify correct state and to preform any other steps necessary before
# the database is locked. This action should raise an exception if the database
# is not in a valid state for a backup.
actions :pre_backup_check

# Cleans up database after backup. This action is called after the backup has
# completed. Can be used to cleanup any temporary files created from the
# :pre_backup_check action.
actions :post_backup_cleanup

# Writes backup information needed during restore. This action is called before
# a backup is done. It contains information about the current database setup
# (database provider, version, replication details, etc.) that is used during
# restore to verify the backup and initialize the database. The file is written
# to the database data block device and is part of the backup.
actions :write_backup_info

# Verifies the database is in a good state before preforming a restore. This
# action is called before a restore is performed. It should be used to verify
# that the system is in a correct state for restoring and should preform any
# other steps necessary before a new block_device is attached and the database
# is stopped for a restore. This action should raise an exception if the
# database is not in a valid state for a restore.
actions :pre_restore_check

# Validates backup and cleans up database after restore. Raise an exception if
# the snapshot is from a different master, from an incompatible database
# software version, incompatible architecture, or other provider dependent
# conditions. This action is called after the block_device restore has completed
# and before the database is started. Used to link the database to the files in
# the newly restored data_dir. Can also be used to perform other steps necessary
# to cleanup after a restore.
actions :post_restore_cleanup

# Sets database user privileges. Use the privilege attributes of this resource to
# setup 'administrator' or 'user' privilege to the given username with the given
# password.
actions :set_privileges

# Installs database client. Use to install the client on any system that needs
# to connect to the server. Also should install language binding packages.
# For example: ruby client gem, java client jar, php client modules, etc
actions :install_client

# Installs database server
actions :install_server

# Installs the driver packages for applications servers based on their driver
# type
actions :install_client_driver

# Installs and configures collectd plugins for the server. This is used by the
# RightScale platform to display metrics about the database on the RightScale
# dashboard. Also enables alerts and escalations for the database.
actions :setup_monitoring

# Configures and starts a slave replicating from master
actions :enable_replication

# Promotes a slave server to the master server. This is called when a new master
# is needed. If the prior master is still functioning it is demoted and
# configured as a slave.
actions :promote

  # Force a slave to promote to master
  attribute :force, :equal_to => [true, false], :default => false

# Sets database replication privileges for a slave. This is called when a slave
# is initialized.
actions :grant_replication_slave
