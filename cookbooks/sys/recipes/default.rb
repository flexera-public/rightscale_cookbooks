#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# By default run the sys::do_reconverge_list_enable recipe
include_recipe "sys::do_reconverge_list_enable"

rightscale_marker :end
