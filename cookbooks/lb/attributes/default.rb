# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Required attributes that determine which provider to use.
default[:lb][:service][:provider] = "lb_haproxy"

# Logical name for the application (balancing group) to use.
default[:lb][:pools] = nil
default[:lb][:host]= nil
default[:server_collection]['app_servers'] = Hash.new

# URI for the load balancer to use to check the health of a server (only used when using http templates).
default[:lb][:health_check_uri] = "/"
# URI that the load balancer uses to publish its status.
default[:lb][:stats_uri] = ""
# Username required to access to the haproxy stats page.
default[:lb][:stats_user] = ""
# Password required to access to the haproxy stats page.
default[:lb][:stats_password] = ""

default[:lb][:session_stickiness] = ""
default[:lb][:max_conn_per_server] = "500"
