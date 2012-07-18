#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

DATA_DIR = node[:db][:data_dir]
log "  Removing anonymous users from database."

db DATA_DIR do
  action :remove_anonymous
end

rightscale_marker :end
