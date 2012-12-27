#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
default[:db_postgres][:server_usage] = "dedicated" # or "shared"
default[:db_postgres][:previous_master] = nil

# Optional attributes
default[:db_postgres][:port] = "5432"

default[:db_postgres][:tmpdir] = "/tmp"
default[:db_postgres][:ident_file] = ""
default[:db_postgres][:pid_file] = ""

# Platform specific attributes
case platform
when "centos", "redhat"
  default[:db_postgres][:packages_uninstall] = ""
  default[:db_postgres][:log] = ""
  default[:db_postgres][:log_error] = ""
end
