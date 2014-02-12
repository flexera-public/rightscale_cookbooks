#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Sets a database server to be a master in a replication db setup.
# The tasks include setting up DNS, setting tags, and setting node attributes.
#
define :db_register_master do

  class Chef::Recipe
    include RightScale::Database::Helper
  end

  class Chef::Resource::Db
    include RightScale::Database::Helper
  end

  # Set master DNS
  # Do this first so that DNS can propagate while the recipe runs
  # See cookbooks/db/libraries/helper.rb
  # for the "get_local_replication_interface" method.
  bind_ip = get_local_replication_interface
  log "  Setting master database #{node[:db][:dns][:master][:fqdn]}" +
    " to #{bind_ip}"
  # See cookbooks/sys_dns/providers/*.rb for the "set" action.
  sys_dns "default" do
    id node[:db][:dns][:master][:id]
    address bind_ip
    action :set
  end

  # Set master tags
  # Tag the server with the master tags rs_dbrepl:master_active
  # and rs_dbrepl:master_instance_uuid

  begin
    # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag
    # for the "right_link_tag" resource.
    right_link_tag "rs_dbrepl:slave_instance_uuid=#{node[:rightscale][:instance_uuid]}" do
      action :remove
    end
  rescue Exception => e
    log "  This server was not previously a slave"
  end

  active_tag = "rs_dbrepl:master_active=#{Time.now.strftime("%Y%m%d%H%M%S")}-#{node[:db][:backup][:lineage]}"
  log "  Tagging server with #{active_tag}"
  right_link_tag active_tag

  unique_tag = "rs_dbrepl:master_instance_uuid=#{node[:rightscale][:instance_uuid]}"
  log "  Tagging server with #{unique_tag}"
  right_link_tag unique_tag

  # Set master node variables
  # See cookbooks/db/definitions/db_state_set.rb
  # for the "db_state_set" definition.
  db_state_set "Set master state" do
    master_uuid node[:rightscale][:instance_uuid]
    master_ip bind_ip
    is_master true
  end

end
