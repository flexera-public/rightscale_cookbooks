#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

module RightScale
  module Database
    module Helper

      require 'yaml'

      DB_MASTER_SLAVE_STATE = "/var/lib/rightscale_db_master_slave_state.json"
      SNAPSHOT_POSITION_FILENAME = "rs_snapshot_position.yaml"

      # Get the current status of the database server.
      #
      # @param [Hash] node Server node name to check.
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

      # Gets the local replication interface.
      #
      # @return [String] interface ip address
      def get_local_replication_interface
        case node[:db][:replication][:network_interface]
        when "private"
          node[:cloud][:private_ips][0]
        when "public"
          node[:cloud][:public_ips][0]
        when "vpn"
          r = %x[rs_tag --list][/server:vpn_ip_0=([\d.]+)/, 1]
          raise "No \"server:vpn_ip_0=\" tag found" if r.nil?
        else
          raise "\"#{node[:db][:replication][:network_interface]}\"" +
            " is not a valid network interface."
        end
      end


      # Set the attribute of a resource during converge phase
      #
      # @param [Hash] resource Hash representing the resource
      # @param [Symbol] attribute attribute to be changed
      # @param [String] value value of the attribute
      #
      # @example Set the attribute of db resource
      #   set_resource_attribute(
      #     {:db => node[:db][:data_dir]},
      #     :dumpfile,
      #     node[:db][:dump][:filepath]
      #   )
      #
      # @note This method should only be called in the converge phase
      #
      def set_resource_attribute(resource, attribute, value)
        resource_found = run_context.resource_collection.find(resource)
        resource_found.method(attribute).call(value)
      end

      # Adjusts values based on a usage factor and create human readable string.
      #
      # @param value [Integer] value to adjust
      # @param units [String] units of the value
      # @param usage_factor [Integer] server usage factor used for adjustment
      #
      # @return [String] adjusted value with units
      def value_with_units(value, units, usage_factor)
        raise "Error: value must convert to an integer." unless value.to_i
        raise "Error: units must be k, m, g" unless units =~ /[KMG]/i
        factor = usage_factor.to_f
        if factor > 1.0 || factor <= 0.0
          raise "Error: usage_factor must be between 1.0 and 0.0." +
            " Value used: #{usage_factor}"
        end
        (value * factor).to_i.to_s + units
      end

      # Loads replication information from 'SNAPSHOT_POSITION_FILENAME'.
      #
      # @param node [Hash] node name
      def self.load_replication_info(node)
        loadfile = ::File.join(node[:db][:data_dir], SNAPSHOT_POSITION_FILENAME)
        Chef::Log.info "  Loading replication information from #{loadfile}"
        YAML::load_file(loadfile)
      end

    end
  end
end
