# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set defaults for HAProxy specific configuration items
default[:lb_haproxy][:algorithm] = 'roundrobin'
default[:lb_haproxy][:timeout_client] = '60000'
default[:lb_haproxy][:timeout_server] = '60000'

# HAProxy tuning parameters
default[:lb_haproxy][:global_maxconn] = 4096
default[:lb_haproxy][:default_maxconn] = 2000
default[:lb_haproxy][:httpclose] = "off"
default[:lb_haproxy][:abortonclose] = "off"
