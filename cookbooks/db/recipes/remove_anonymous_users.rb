#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Anonymous users are created by default by MySQl to allow users access the database
# without using a username and password.
# For more information, visit 
# http://dev.mysql.com/doc/refman/5.5/en/default-privileges.html

# This recipe removes anonymous users acces from any hosts except localhost to
# prevent remote unauthorized access.

rightscale_marker :begin

DATA_DIR = node[:db][:data_dir]
log "  Removing anonymous users from database."

# See cookbooks/db_<provider>/providers/default.rb for "remove_anonymous" action.
db DATA_DIR do
  action :remove_anonymous
end

rightscale_marker :end
