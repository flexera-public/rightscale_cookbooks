#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Optional attributes

# Remote logging server
default[:logging][:remote_server] = ""
# Protocol used for sending log messages
default[:logging][:protocol] = "udp"
# SSL certificate for logging
default[:logging][:certificate] = ""
