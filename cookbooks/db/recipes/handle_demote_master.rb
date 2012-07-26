#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Clear master tag
unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "  Clearing tag #{unique_tag}"
right_link_tag unique_tag do
  action :remove
end

# Set master node variables
db_state_set "Set slave state" do
  master_uuid node[:remote_recipe][:new_master_uuid]
  master_ip node[:remote_recipe][:new_master_ip]
end

rightscale_marker :end
