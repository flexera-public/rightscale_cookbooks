#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Default setting for DB FQDN
default[:db][:dns][:master][:fqdn] = "localhost"

# Initial settings for client operations on application servers
default[:db][:data_dir] = "/mnt/storage"

# Default settings for database administrator user and password
default[:db][:admin][:user] = "root"
default[:db][:admin][:password] = ""

# Default settings for database replication user and password
default[:db][:replication][:user] = nil
default[:db][:replication][:password] = nil

# Default settings for backup lineage
default[:db][:backup][:lineage] = ""
default[:db][:backup][:lineage_override] = ""

# TTL limit to verify Master DB DNS TTL
default[:db][:dns][:ttl] = "60"

# Database driver class to be used based on the type of driver
set_unless[:db][:client][:driver] = ""

# Server state variables
#
# Default value for DB status
# valid values are :initialized or :uninitialized
default[:db][:init_status] = :uninitialized

# Default value for DB master/slave check
default[:db][:this_is_master] = false

# Instance UUID and ip default values
default[:db][:current_master_uuid] = nil
default[:db][:current_master_ip] = nil


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
default[:db][:backup][:primary][:master][:cron][:hour] = cron_h
default[:db][:backup][:primary][:master][:cron][:minute] = cron_min

# Slave backup every hour at a random minute 30 minutes offset from the master.
default[:db][:backup][:primary][:slave][:cron][:hour] = "*" # every hour
default[:db][:backup][:primary][:slave][:cron][:minute] = cron_min + 30

# DB manager type specific commands array for db_sys_info.log file
default[:db][:info_file_options] = []
default[:db][:info_file_location] = "/etc"

set_unless[:db][:port] = ""