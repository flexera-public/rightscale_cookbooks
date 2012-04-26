#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

begin
  require 'rightscale_tools'
rescue LoadError
  Chef::Log.warn("Missing gem 'rightscale_tools'")
end


module RightScale
  module BlockDeviceHelper

    def init(new_resource)
      # Setup options
      options = {
        :hypervisor => new_resource.hypervisor,
        :primary_endpoint => new_resource.primary_endpoint,
        :secondary_endpoint => new_resource.secondary_endpoint
      }
      options[:rackspace_use_snet] = new_resource.rackspace_snet if new_resource.rackspace_snet

      # Primary ROS options
      options[:primary_storage_cloud] = new_resource.primary_cloud if new_resource.primary_cloud
      options[:primary_storage_key] = new_resource.primary_user if new_resource.primary_user
      options[:primary_storage_secret] = new_resource.primary_secret if new_resource.primary_secret
      options[:primary_storage_container] = new_resource.lineage if new_resource.lineage

      # Secondary ROS options
      options[:secondary_storage_cloud] = new_resource.secondary_cloud if new_resource.secondary_cloud
      options[:secondary_storage_key] = new_resource.secondary_user if new_resource.secondary_user
      options[:secondary_storage_secret] = new_resource.secondary_secret if new_resource.secondary_secret
      options[:secondary_storage_container] = new_resource.secondary_container if new_resource.secondary_container

      # Create and return BlockDevice object
      ::RightScale::Tools::BlockDevice.factory(
          :lvm,                     # Backup using local LVM snapshot + cloud persistence.
          node[:cloud][:provider],  # The local cloud that we are currently running.
          new_resource.mount_point,
          new_resource.nickname,    # Nickname for device.
          options)
    end

    def secondary_checks(new_resource)
      [:secondary_user, :secondary_secret, :secondary_cloud, :secondary_container].each do |input|
        value = new_resource.method(input).call
        raise "Must set #{input} to run secondary backup/restore." unless value && !value.empty?
      end
    end

    def do_for_all_block_devices(block_device, &block)
      RightScale::BlockDeviceHelper.do_for_all_block_devices(block_device, &block)
    end

    def do_for_block_devices(block_device, &block)
      RightScale::BlockDeviceHelper.do_for_block_devices(block_device, &block)
    end

    def self.do_for_all_block_devices(block_device, &block)
      block_device[:devices].keys.reject do |key|
        key == 'default'
      end.sort.each_with_index.map do |device, index|
        [device, index + 1]
      end.each do |device, number|
        block.arity == 1 ? block[device] : block[device, number]
      end
    end

    def self.do_for_block_devices(block_device, &block)
      devices_to_use = block_device[:devices_to_use]

      if devices_to_use == '*'
        do_for_all_block_devices(block_device, &block)
      else
        devices = Hash[block_device[:devices].keys.reject do |key|
          key == 'default'
        end.sort.each_with_index.map do |device, index|
          [device, index + 1]
        end]
        devices_to_use.split(',').each do |device|
          number = devices[device]
          raise "Invalid device: #{device}" unless number
          block.arity == 1 ? block[device] : block[device, number]
        end
      end
    end

    # XXX: this should probably go into rs_util
    def self.set_unless_deep_merge(node, src, dst)
      src.reduce(node) {|values, key| values[key]}.each_pair do |attribute, value|
        case value
        when Mash, Chef::Node::Attribute
          set_unless_deep_merge(node, src + [attribute], dst + [attribute])
        else
          dst.reduce(node.set_unless) {|values, key| values[key]}[attribute] = value
        end
      end
    end

    def get_device_or_default(node, device, *keys)
      RightScale::BlockDeviceHelper.get_device_or_default(node, device, *keys)
    end

    def self.get_device_or_default(node, device, *keys)
      value = keys.reduce(node[:block_device][:devices][device]) do |values, key|
        break nil if values == nil
        values[key]
      end
      value = keys.reduce(node[:block_device][:devices][:default]) {|values, key| values[key]} if !value || value.empty?
      value
    end
  end
end
