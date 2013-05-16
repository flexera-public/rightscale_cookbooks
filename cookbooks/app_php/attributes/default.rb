#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# List of additional php modules
default[:app_php][:modules_list] = []
# List of required apache modules
default[:app_php][:module_dependencies] = []
