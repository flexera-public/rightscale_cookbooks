#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Default setting for DB FQDN
set_unless[:db][:dns][:master][:fqdn] = "localhost"

# DB Provider, type of database which will be initialized
# can be db_mysql or db_postgres, for more info please refer to corresponding cookbooks
#set_unless[:db][:provider] = "db_mysql"

# Initial set of node[:db][:data_dir] for db::install client correct operations
# on application servers
set_unless[:db][:data_dir] = "/mnt/storage"
set_unless[:db][:database_adapter] = "db_mysql_5.1"

# Default settings for database administrator user and password
set_unless[:db][:admin][:user] = "root"
set_unless[:db][:admin][:password] = ""

# Default settings for database replication user and password
set_unless[:db][:replication][:user] = nil
set_unless[:db][:replication][:password] = nil

# Default settings for backup lineage
set_unless[:db][:backup][:lineage] = ""
set_unless[:db][:backup][:lineage_override] = ""

# TTL limit to verify Master DB DNS TTL
set_unless[:db][:dns][:ttl] = "60"


# Server state variables
#
# Default value for DB status
# valid values are :initialized or :uninitialized
set_unless[:db][:init_status] = :uninitialized

# Default value for DB master/slave check
set_unless[:db][:this_is_master] = false

# Instance UUID and ip default values
set_unless[:db][:current_master_uuid] = nil
set_unless[:db][:current_master_ip] = nil


# Calculate recommended backup times for master/slave
#
#  Offset the start time by a random number.  Skip the minutes near the exact hour and 1/2 hour.  This is done to prevent
#  overloading the API and cloud providers.  If every rightscale server sent a request at the same
#  time to perform a snapshot it would be a huge usage spike.  The random start time even out these spikes.

# Generate random time
# Master and slave backup times are staggered by 30 minutes.
cron_h = rand(23)
cron_min = 5 + rand(24)

# Master backup daily at a random hour and a random minute between 5-29
set_unless[:db][:backup][:primary][:master][:cron][:hour] = cron_h
set_unless[:db][:backup][:primary][:master][:cron][:minute] = cron_min

# Slave backup every hour at a random minute 30 minutes offset from the master.
set_unless[:db][:backup][:primary][:slave][:cron][:hour] = "*" # every hour
set_unless[:db][:backup][:primary][:slave][:cron][:minute] = cron_min + 30
