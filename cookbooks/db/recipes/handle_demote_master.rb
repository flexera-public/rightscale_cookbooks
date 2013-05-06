#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Clear master tags
master_instance_uuid_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
log "  Clearing tag #{master_instance_uuid_tag}"

# See support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
right_link_tag master_instance_uuid_tag do
  action :remove
end

# Set master node variables
# See cookbooks/db/definitions/db_state_set.rb for the "db_state_set" definition.
db_state_set "Set slave state" do
  master_uuid node[:remote_recipe][:new_master_uuid]
  master_ip node[:remote_recipe][:new_master_ip]
end

# Add server tag to visually show a slave
# See cookbooks/db/definitions/db_register_slave.rb for the "db_register_slave" definition.
db_register_slave "tagging slave" do
  action :only_tag
end
