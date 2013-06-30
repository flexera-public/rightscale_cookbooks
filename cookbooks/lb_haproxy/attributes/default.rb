#
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Haproxy algorithm
default[:lb_haproxy][:algorithm] = 'roundrobin'
# Haproxy client timeout
default[:lb_haproxy][:timeout_client] = '60000'
# Haproxy server timeout
default[:lb_haproxy][:timeout_server] = '60000'

