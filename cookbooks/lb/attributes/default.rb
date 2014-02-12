#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Required attributes that determine which provider to use.
default[:lb][:service][:provider] = "lb_client"

# Recommended attributes

# Logical name for the application (balancing group) to use.
default[:lb][:pools] = "default"
# Load balancer provider
default[:lb][:service][:provider] = "lb_client"
# Load balancer host
default[:lb][:host]= ""
default[:server_collection]['app_servers'] = Hash.new
# Maximum connections per server
default[:lb][:max_conn_per_server] = "500"

# Optional attributes

# URI for the load balancer to use to check the health of a server
# (only used when using http templates).
default[:lb][:health_check_uri] = "/"
# URI that the load balancer uses to publish its status.
default[:lb][:stats_uri] = "/haproxy-status"
# Username required to access to the stats page.
default[:lb][:stats_user] = ""
# Password required to access to the stats page.
default[:lb][:stats_password] = ""
# Whether to use session stickiness
default[:lb][:session_stickiness] = "true"
# Load balancer service region
default[:lb][:service][:region] = "ORD (Chicago)"
# Load balancer service name
default[:lb][:service][:lb_name] = ""
# Load balancer service account ID
default[:lb][:service][:account_id] = ""
# Load balancer service secret
default[:lb][:service][:account_secret] = ""
