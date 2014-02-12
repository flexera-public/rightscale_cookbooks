#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Optional attributes

# Reconverge list
default[:sys][:reconverge_list] = ""
# Defines the interval in minutes to run recipe(s) in reconverge list.
default[:sys][:reconverge][:interval] = "15"
# Defines the plus/minus offset of reconverge interval to avoid all systems
# from reconverging at the same time.
default[:sys][:reconverge][:splay] = "10"
