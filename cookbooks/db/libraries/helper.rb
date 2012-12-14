#
# Cookbook Name:: db_mysql
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Database
    module Helper
      DB_MASTER_SLAVE_STATE = "/var/lib/rightscale_db_master_slave_state.json"

      # Get the current status of the database server.
      #
      # @param [Hash] db_state_get Server node name to check.
      def db_state_get(node)
        Chef::Log.info "  Loading master/slave state"
        state = ::File.exist?(DB_MASTER_SLAVE_STATE) ? JSON.load(::File.read(DB_MASTER_SLAVE_STATE)) : {
          "master_uuid" => nil,
          "master_ip" => nil,
          "is_master" => false
        }
        node[:db][:current_master_uuid] = master_uuid = state["master_uuid"]
        node[:db][:current_master_ip] = master_ip = state["master_ip"]
        node[:db][:this_is_master] = is_master = state["is_master"]
        Chef::Log.info "  Loaded master/slave state: master UUID: #{master_uuid} IP: #{master_ip} this is #{is_master ? "master" : "slave"}"
      end
    end
  end
end
