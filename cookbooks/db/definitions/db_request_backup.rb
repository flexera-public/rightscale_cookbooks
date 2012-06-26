#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Perform backup request, will execute db::do_primary/secondary_backup recipe depending of backup_type given
#
# @param force [Boolean] If false, if a backup is currently running, will error out stating so.
#   If true, if a backup is currently running, will kill that process and take over the lock.
# @param backup_type [String] If 'primary' will do a primary backup using node attributes specific
#   to the main backup.  If 'secondary' will do a secondary backup using node attributes for
#   secondary.  Secondary uses 'ROS'.
define :db_request_backup, :force => false, :backup_type => 'primary' do
  do_force        = params[:force]
  do_backup_type  = params[:backup_type] == "primary" ? "primary" : "secondary"

  remote_recipe "Request #{do_backup_type} backup" do
    recipe "db::do_#{do_backup_type}_backup"
    attributes :db => {:backup => {:force => "#{do_force}"}}
    recipients_tags "server:uuid=#{node[:rightscale][:instance_uuid]}"
  end
end
