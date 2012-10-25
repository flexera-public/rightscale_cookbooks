#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Attempt to return the instance to a pristine / newly launched state.
# This is for development and test purpose and should not be used on
# production servers.

rightscale_marker :begin

raise "Force reset safety not off.  Override db/force_safety to run this recipe" unless node[:db][:force_safety] == "off"

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

log "  Brute force tear down of the setup..."

DATA_DIR = node[:db][:data_dir]
# See cookbooks/block_device/libraries/block_device.rb for
# "get_device_or_default" method.
NICKNAME = get_device_or_default(node, :device1, :nickname)

log "  Resetting the database..."
db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for "reset" action.
  action :reset
end

log "  Resetting block device..."
block_device NICKNAME do
  lineage node[:db][:backup][:lineage]
  # See cookbooks/block_device/providers/default.rb for "reset" action.
  action :reset
end

log "  Remove tags..."
tags_to_remove = `rs_tag --list | grep rs_dbrepl`
tags_to_remove.each do |each_tag|
  each_tag = each_tag.strip.chomp.chomp(',').gsub(/^\"|\"$/, '')
  log "  Remove #{each_tag}..."
  bash "remove tags" do
    flags "-ex"
    code <<-EOH
      rs_tag -r '#{each_tag}'
    EOH
  end
end

# See cookbooks/db/libraries/helper.rb for "db_state_set" method.
db_state_set "Reset master/slave state"

log "  Resetting database, then starting database..."
db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for
  # "reset" and "start" actions.
  action [ :reset, :start ]
end

log "  Setting database state to 'uninitialized'..."
# See cookbooks/db/definitions/db_init_status.rb for
# "db_init_status" definition.
db_init_status :reset

log "  Cleaning cron..."
block_device NICKNAME do
  cron_backup_recipe "#{self.cookbook_name}::do_primary_backup"
  # See cookbooks/block_device/providers/default.rb for
  # "backup_schedule_disable" action.
  action :backup_schedule_disable
end

log "  Resetting collectd config..."
db DATA_DIR do
  # See cookbooks/db_<provider>/providers/default.rb for
  # "setup_monitoring" action.
  action :setup_monitoring
end

rightscale_marker :end
