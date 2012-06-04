#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


rightscale_marker :begin

raise "Server terminate safety not off.  Override db/terminate_safety to run this recipe" unless node[:db][:terminate_safety] == "off"

class Chef::Recipe
  include RightScale::BlockDeviceHelper
end

DATA_DIR = node[:db][:data_dir]
NICKNAME = get_device_or_default(node, :device1, :nickname)

log "  Resetting the database..."
db DATA_DIR do
  action :reset
end

log "  Detach and delete volume..."
block_device NICKNAME do
  action :reset
end

rs_shutdown "Terminate the server now" do
  # And shutdown regardless of any errors.
  immediately true
  action :terminate
end

rightscale_marker :end
