#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Required attributes

# DNS service provider
default[:sys_dns][:choice] = ""
# DNS Record ID
default[:sys_dns][:id] = ""
# DNS user
default[:sys_dns][:user] = ""
# DNS password
default[:sys_dns][:password] = ""

# Optional attributes

# Cloud DNS region
default[:sys_dns][:region] = ""
