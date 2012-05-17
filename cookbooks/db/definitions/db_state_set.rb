#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set or reset the master/slave status, UUID, and IP.
#
# @param [String, nil] master_uuid the UUID of the master server to set
# @param [String, nil] master_ip the IP address of the master server to set
# @param [Boolean] is_master set whether this server is the master
# @param [Boolean] immediate run the resource actions immediately
#
define :db_state_set, :master_uuid => nil, :master_ip => nil, :is_master => false, :immediate => false do
  class Chef::Recipe
    include RightScale::Database::Helper
  end

  name = params[:name]
  master_uuid = params[:master_uuid]
  master_ip = params[:master_ip]
  is_master = params[:is_master]
  immediate = params[:immediate]

  r = log "#{name}: master UUID: #{master_uuid} IP: #{master_ip} this is #{is_master ? "master" : "slave"}" do
    action immediate ? :nothing : :write
  end
  r.run_action(:write) if immediate

  r = ruby_block "#{name}: set in node" do
    block do
      node[:db][:current_master_uuid] = master_uuid
      node[:db][:current_master_ip] = master_ip
      node[:db][:this_is_master] = is_master
    end
    action immediate ? :nothing : :create
  end
  r.run_action(:create) if immediate

  r = file DB_MASTER_SLAVE_STATE do
    backup false
    content JSON.dump({
      "master_uuid" => master_uuid,
      "master_ip" => master_ip,
      "is_master" => is_master
    })
    action immediate ? :nothing : :create
  end
  r.run_action(:create) if immediate
end
