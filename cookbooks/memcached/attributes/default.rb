#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

# Default values for variables needed for the memcached server installation.
# Will get set unless provided by user input.

# Memcached TCP port
default[:memcached][:tcp_port] = "11211"
# Memcached UDP port
default[:memcached][:udp_port] = "11211"
# Memcached user
default[:memcached][:user] = "nobody"
# Memcached connection limit
default[:memcached][:connection_limit] = "1024"
# Memcached cache size percentage
default[:memcached][:memtotal_percent] = "90"
# Memcached user threads
default[:memcached][:threads] = "1"
# Memcached listening interface
default[:memcached][:interface] = "any"

# Optional attributes

# Memcached logging output level
default[:memcached][:log_level] = "off"
# Memcached cluster ID
default[:memcached][:cluster_id] = "cache_cluster"
