#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes

default[:db_mysql][:collectd_master_slave_mode] = ""

# Optional attributes

default[:db_mysql][:port] = "3306"
default[:db_mysql][:log_bin_enabled] = true
default[:db_mysql][:log_bin] = "/mnt/ephemeral/mysql-binlogs/mysql-bin"
default[:db_mysql][:binlog_format] = "MIXED"
default[:db_mysql][:tmpdir] = "/mnt/ephemeral/mysqltmp"
default[:db_mysql][:datadir] = "/var/lib/mysql"
default[:db_mysql][:enable_mysql_upgrade] = "false"
default[:db_mysql][:compressed_protocol] = "disabled"
# Always set to support stop/start
set[:db_mysql][:bind_address] = "0.0.0.0"

default[:db_mysql][:dump][:storage_account_provider] = ""
default[:db_mysql][:dump][:storage_account_id] = ""
default[:db_mysql][:dump][:storage_account_secret] = ""
default[:db_mysql][:dump][:container] = ""
default[:db_mysql][:dump][:prefix] = ""

default[:db_mysql][:server_usage] = "shared"
default[:db_mysql][:init_timeout] = "600"
default[:db_mysql][:tunable][:expire_logs_days] = "2"
default[:db_mysql][:tunable][:isamchk] = {}
default[:db_mysql][:tunable][:myisamchk] = {}

# SSL attributes
default[:db_mysql][:ssl][:ca_certificate] = ""
default[:db_mysql][:ssl][:master_certificate] = ""
default[:db_mysql][:ssl][:master_key] = ""
default[:db_mysql][:ssl][:slave_certificate] = ""
default[:db_mysql][:ssl][:slave_key] = ""

# Platform specific attributes

case platform
when "redhat", "centos"
  default[:db_mysql][:log] = ""
  default[:db_mysql][:log_error] = ""
when "ubuntu"
  default[:db_mysql][:log] = "log = /var/log/mysql.log"
  default[:db_mysql][:log_error] = "log_error = /var/log/mysql.err"
else
  raise "Unsupported platform #{platform}"
end

# System tuning parameters
# Set the mysql and root users max open files to a really large number.
# 1/3 of the overall system file max should be large enough.
# The percentage can be adjusted if necessary.
default[:db_mysql][:file_ulimit] = `sysctl -n fs.file-max`.to_i/33

default[:db_mysql][:backup][:slave][:max_allowed_lag] = 60
