#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Adding #{node[:db][:admin][:user]} user with privileges for ALL databases."

# See cookbooks/db/definitions/db_set_privileges.rb for the "db_set_privileges" definition.
db_set_privileges [{:role => "administrator", :username => node[:db][:admin][:user], :password => node[:db][:admin][:password]}]

rightscale_marker :end
