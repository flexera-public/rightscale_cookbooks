#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

require 'mixlib/shellout'

def value_with_units(value, units, usage_factor)
  raise "Error: value must convert to an integer." unless value.to_i
  raise "Error: units must be k, m, g" unless units =~ /[KMG]B/i
  factor = usage_factor.to_f
  if factor > 1.0 || factor <= 0.0
    raise "Error: usage_factor must be between 1.0 and 0.0." +
     "Value used: #{usage_factor}"
  end
  (value * factor).to_i.to_s + units
end

# Shared servers get %50 of the resources allocated to a dedicated server.
usage = 1 # Dedicated server
usage = 0.5 if db_postgres[:server_usage] == "shared"

# Ohai returns total in KB.  Set GB so X*GB can be used in conditional
# GB=1024*1024
mem = memory[:total].to_i/1024
Chef::Log.info("  Auto-tuning PostgreSQL parameters.  Total memory: #{mem}MB")
twenty_five_percent_mem = (mem * 0.25).to_i
twenty_five_percent_str = value_with_units(twenty_five_percent_mem, "MB", usage)

# Set tuning parameters.
ulimit = Mixlib::ShellOut.new("sysctl -n fs.file-max")
ulimit.run_command
ulimit.error!
default[:db_postgres][:tunable][:ulimit] = ulimit.stdout.to_i/33
default[:db_postgres][:tunable][:max_connections] = (400 * usage).to_i
default[:db_postgres][:tunable][:shared_buffers] = twenty_five_percent_str

