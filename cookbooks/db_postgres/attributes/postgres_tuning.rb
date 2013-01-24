#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


def value_with_units(value, units, usage_factor)
  raise "Error: value must convert to an integer." unless value.to_i
  raise "Error: units must be k, m, g" unless units =~ /[KMG]B/i
  factor = usage_factor.to_f
  raise "Error: usage_factor must be between 1.0 and 0.0. Value used: #{usage_factor}" if factor > 1.0 || factor <= 0.0
  (value * factor).to_i.to_s + units
end

# Set tuning parameters.

default[:db_postgres][:tunable][:ulimit] = `sysctl -n fs.file-max`.to_i/33
default[:db_postgres][:tunable][:shared_buffers] = "24MB"
default[:db_postgres][:tunable][:max_connections] = "100"


# Shared servers get %50 of the resources allocated to a dedicated server.
usage = 1 # Dedicated server
usage = 0.5 if db_postgres[:server_usage] == "shared"

# Ohai returns total in KB.  Set GB so X*GB can be used in conditional
# GB=1024*1024
mem = memory[:total].to_i/1024
Chef::Log.info("  Auto-tuning PostgreSQL parameters.  Total memory: #{mem}MB")
one_percent_mem = (mem*0.01).to_i
one_percent_str = value_with_units(one_percent_mem, "MB", usage)
eighty_percent_mem = (mem*0.80).to_i
eighty_percent_str = value_with_units(eighty_percent_mem, "MB", usage)

