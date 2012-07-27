#
# Cookbook Name::memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#
set_unless[:memcached][:tcp_port] = "11211"
set_unless[:memcached][:udp_port] = "11211"
set_unless[:memcached][:user] = "nobody"
set_unless[:memcached][:connection_limit] = "1024"
set_unless[:memcached][:memtotal_percent] = "90"
set_unless[:memcached][:threads] = "1"
set_unless[:memcached][:interface] = "any"
set_unless[:memcached][:log_level] = "off"
set_unless[:memcached][:cluster_id] = ""
