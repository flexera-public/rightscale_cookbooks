#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Checking if state of db is 'uninitialized'..."
db_init_status :check

log "  Running a normal primary backup..."
db_do_backup "do backup" do
  backup_type "primary"
end

rightscale_marker :end
