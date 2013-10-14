#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Perform backup request, will execute db::do_primary/secondary_backup recipe
# depending of backup_type given
#
# @param backup_type [String] If 'primary' will do a primary backup using node
#   attributes specific to the main backup. If 'secondary' will do a secondary
#   backup using node attributes for secondary. Secondary uses 'ROS'.
#
define :db_request_backup, :backup_type => 'primary' do
  do_backup_type = params[:backup_type] == "primary" ? "primary" : "secondary"

  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Chef_Resources#RemoteRecipe
  # for the "remote_recipe" resource.
  # See cookbooks/db/recipes/do_primary_backup.rb for the "db::do_primary_backup" recipe.
  # See cookbooks/db/recipes/do_secondary_backup.rb for the "db::do_secondary_backup" recipe.
  remote_recipe "Request #{do_backup_type} backup" do
    recipe "db::do_#{do_backup_type}_backup"
    recipients_tags "server:uuid=#{node[:rightscale][:instance_uuid]}"
  end
end
