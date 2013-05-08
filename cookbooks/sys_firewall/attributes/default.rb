#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Optional attributes

# Enable/disable firewall
default[:sys_firewall][:enabled] = "enabled"
# Firewall rule IP address
default[:sys_firewall][:rule][:ip_address] = "any"

# Required attributes

# Firewall rule port
default[:sys_firewall][:rule][:port] = ""
# Enable/disable firewall rule
default[:sys_firewall][:rule][:enable] = "enable"
# Firewall rule protocol
default[:sys_firewall][:rule][:protocol] = "tcp"
