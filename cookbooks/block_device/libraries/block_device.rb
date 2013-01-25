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

    # Create new BlockDevice object
    #
    # @param [Object] new_resource Resource which will be initialized
    #
    # @return [BlockDevice] BlockDevice object
    def init(new_resource, backup_type = :primary)
      # Setup options
      options = {
        :hypervisor => new_resource.hypervisor
      }
      options[:rackspace_use_snet] = new_resource.rackspace_snet if new_resource.rackspace_snet
      # Appends RightScale instance uuid to make the nickname unique.
      modified_nickname = new_resource.nickname + '_' + node[:block_device][:first_server_uuid] if new_resource.nickname

      # Primary ROS options - some options needed regardless of backup type
      options[:primary_storage_cloud] = new_resource.primary_cloud if new_resource.primary_cloud
      options[:primary_endpoint] = new_resource.primary_endpoint unless !new_resource.primary_endpoint || new_resource.primary_endpoint.empty?
      options[:primary_storage_key] = new_resource.primary_user if new_resource.primary_user
      options[:primary_storage_secret] = new_resource.primary_secret if new_resource.primary_secret
      options[:primary_storage_container] = new_resource.lineage

      # Secondary ROS options if doing secondary backup
      if backup_type == :secondary
        options[:secondary_storage_cloud] = new_resource.secondary_cloud if new_resource.secondary_cloud
        options[:secondary_endpoint] = new_resource.secondary_endpoint unless !new_resource.secondary_endpoint || new_resource.secondary_endpoint.empty?
        options[:secondary_storage_key] = new_resource.secondary_user if new_resource.secondary_user
        options[:secondary_storage_secret] = new_resource.secondary_secret if new_resource.secondary_secret
        options[:secondary_storage_container] = new_resource.secondary_container if new_resource.secondary_container
      end

      # Create and return BlockDevice object
      ::RightScale::Tools::BlockDevice.factory(
        :lvm, # Backup using local LVM snapshot + cloud persistence.
        node[:cloud][:provider], # The local cloud that we are currently running.
        new_resource.mount_point,
        modified_nickname, # Nickname for device.
        options)
    end

    # Perform checks to prevent empty values of attributes which are required to get
    # backup files from cloud storage
    #
    # @param [Object] new_resource Resource which will be initialized
    #
    # @raises [RuntimeError] if any of required parameters has no value
    def secondary_checks(new_resource)
      [:secondary_user, :secondary_secret, :secondary_cloud, :secondary_container].each do |input|
        value = new_resource.method(input).call
        raise "Must set #{input} to run secondary backup/restore." unless value && !value.empty?
      end
    end

    # Instance method for do_for_all_block_devices
    # will call RightScale::BlockDeviceHelper.do_for_all_block_devices with given parameters
    #
    # @param [Hash] block_device Block device
    # @param [Object] block Hash of block devices to which block_device belongs to
    def do_for_all_block_devices(block_device, &block)
      RightScale::BlockDeviceHelper.do_for_all_block_devices(block_device, &block)
    end

    # Instance method for do_for_block_devices
    # will call RightScale::BlockDeviceHelper.do_for_block_devices with given parameters
    #
    # @param [Hash] block_device Block device
    # @param [Object] block Hash of block devices to which block_device belongs to
    def do_for_block_devices(block_device, &block)
      RightScale::BlockDeviceHelper.do_for_block_devices(block_device, &block)
    end

    # Helper to perform perform actions to a set of all available block devices
    #
    # @param [Hash] block_device Block device
    # @param [Proc] block Block which will be used for setup of all available block device resources.
    def self.do_for_all_block_devices(block_device, &block)
      block_device[:devices].keys.reject do |key|
        key == 'default'
      end.sort.each_with_index.map do |device, index|
        [device, index + 1]
      end.each do |device, number|
        block.arity == 1 ? block[device] : block[device, number]
      end
    end

    # Helper to perform perform actions to a set of block devices
    #
    # @param [Hash] block_device Block device
    # @param [Proc] block Block which will be used for setup of block device resource
    #
    # @raises [RuntimeError] if block device has no number
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

    # Instance method for get_device_or_default
    # will call RightScale::BlockDeviceHelper.get_device_or_default with given parameters
    #
    # @param [Hash] node Node name
    # @param [Symbol] device Device
    # @param [Array] keys Array of keys
    def get_device_or_default(node, device, *keys)
      RightScale::BlockDeviceHelper.get_device_or_default(node, device, *keys)
    end

    # Return current device
    #
    # @param [Hash] node Node name
    # @param [Symbol] device Device
    # @param [Array] keys Array of keys
    def self.get_device_or_default(node, device, *keys)
      value = keys.reduce(node[:block_device][:devices][device]) do |values, key|
        break nil if values == nil
        values[key]
      end
      value = keys.reduce(node[:block_device][:devices][:default]) { |values, key| values[key] } if !value || value.empty?
      value
    end

    # Returns true if fstab and mtab entry exists for ephemeral mount point
    #
    # @param [String] fstab_entry Fstab entry
    # @param [String] mount_point Mount point of the ephemeral drive
    # @param [String] filesystem_type Filesystem type
    def ephemeral_fstab_and_mtab_checks(fstab_entry, mount_point, filesystem_type)
      fstab_exists = File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$")
      mtab_exists = File.open('/etc/mtab', 'r') { |f| f.read }.match(" #{mount_point} #{filesystem_type} ")
      fstab_exists && mtab_exists
    end

    # Calculates and print out restore params
    # and returns the array of ready to use values.
    #
    # @param [String] lineage Lineage input value
    # @param [String] lineage_override Lineage override input value
    # @param [String] restore_timestamp_override Restore timestamp override input value
    #
    # @return [Array] Array of calculated values
    def set_restore_params(lineage, lineage_override, restore_timestamp_override)
      restore_lineage = lineage_override == nil || lineage_override.empty? ? lineage : lineage_override

      Chef::Log.info "  Input lineage #{restore_lineage.inspect}"
      Chef::Log.info "  Input lineage_override #{lineage_override.inspect}"
      Chef::Log.info "  Using lineage #{restore_lineage.inspect}"
      Chef::Log.info "  Input timestamp_override #{restore_timestamp_override.inspect}"

      restore_timestamp_override ||= ""

      value = [restore_lineage, restore_timestamp_override]
      value
    end

  end
end
