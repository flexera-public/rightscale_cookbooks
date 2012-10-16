#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Adding #{node[:db][:application][:user]} with CRUD privileges for ALL databases."

db_set_privileges [{:role => "user", :user => node[:db][:application][:user], :password => node[:db][:application][:password]}]

rightscale_marker :end
