#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Checking if state of db is 'uninitialized'..."
db_init_status :check

log "  Run a normal primary backup..."
db_do_backup "do backup" do
  force node[:db][:backup][:force] == 'true'
  backup_type "primary"
end

log "  Setting database state to 'initialized'..."
db_init_status :set

rightscale_marker :end
