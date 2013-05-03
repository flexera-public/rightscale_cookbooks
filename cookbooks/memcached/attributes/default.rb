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

default[:memcached][:tcp_port] = "11211"
default[:memcached][:udp_port] = "11211"
default[:memcached][:user] = "nobody"
default[:memcached][:connection_limit] = "1024"
default[:memcached][:memtotal_percent] = "90"
default[:memcached][:threads] = "1"
default[:memcached][:interface] = "any"
default[:memcached][:log_level] = "off"
default[:memcached][:cluster_id] = "cache_cluster"
