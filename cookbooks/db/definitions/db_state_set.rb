#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Set or reset the master/slave status, UUID, and IP.
#
# @param master_uuid [String, nil] the UUID of the master server to set
# @param master_ip [String, nil] the IP address of the master server to set
# @param is_master [Boolean] set whether this server is the master
# @param immediate [Boolean] run the resource actions immediately
define :db_state_set, :master_uuid => nil, :master_ip => nil, :is_master => false, :immediate => false do
  name = params[:name]
  master_uuid = params[:master_uuid]
  master_ip = params[:master_ip]
  is_master = params[:is_master]
  immediate = params[:immediate]

  r = log "  #{name}: master UUID: #{master_uuid} IP: #{master_ip} this is #{is_master ? "master" : "slave"}" do
    action :nothing if immediate
  end
  r.run_action(:write) if immediate

  r = ruby_block "#{name}: set in node" do
    block do
      node[:db][:current_master_uuid] = master_uuid
      node[:db][:current_master_ip] = master_ip
      node[:db][:this_is_master] = is_master
    end
    action :nothing if immediate
  end
  r.run_action(:create) if immediate

  r = file RightScale::Database::Helper::DB_MASTER_SLAVE_STATE do
    backup false
    content JSON.dump({
      "master_uuid" => master_uuid,
      "master_ip" => master_ip,
      "is_master" => is_master
    })
    action :nothing if immediate
  end
  r.run_action(:create) if immediate
end
