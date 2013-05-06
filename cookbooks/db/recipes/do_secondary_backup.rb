#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# See cookbooks/db/definitions/db_do_backup.rb for the "db_do_backup" definition.
db_do_backup "do secondary backup" do
  backup_type "secondary"
end
