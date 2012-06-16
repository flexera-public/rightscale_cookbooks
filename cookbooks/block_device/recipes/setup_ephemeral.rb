#
# Cookbook Name:: block_device
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

require 'fileutils'

package "lvm2"

package "xfsprogs" do
  not_if { node[:platform] == "redhat" }
end

cloud = node[:cloud][:provider]

# Generate fstab entry and check if entry already in fstab - assuming a reboot
mount_point = "/mnt/ephemeral"
lvm_device = "lvol0"

# Ubuntu systems using upstart require the 'bootwait' option, otherwise
# upstart will try to boot without waiting for the LVM volume to be mounted.
options = "defaults,noatime"
if node[:platform] == "ubuntu"
  options += ",bootwait,noauto"
end

# RedHat does not support xfs, so set specific item accordingly
if node[:platform] == "redhat"
  filesystem_type = "ext3"
else
  filesystem_type = "xfs"
end

root_device = `mount`.find {|dev| dev.include? " on / "}.split[0]

current_mnt_device = `mount`.find {|dev| dev.include? " on /mnt "}
current_mnt_device = current_mnt_device ? current_mnt_device.split[0] : nil

# Only EC2 and openstack is currently supported
if cloud == 'ec2' || cloud == 'openstack'

  # Get a list of ephemeral devices
  # Make sure to skip EBS volumes attached on boot
  @api = RightScale::Tools::API.factory('1.0') if cloud == 'ec2'
  my_devices = []
  dev_index = 0
  loop do
    if node[cloud][:block_device_mapping]["ephemeral#{dev_index}"]
      device = node[cloud][:block_device_mapping]["ephemeral#{dev_index}"]
      device = '/dev/' + device if device !~ /^\/dev\//
      device = @api.unmap_device_for_ec2(device) if cloud == 'ec2'
      # verify that device is actually on the instance and is a blockSpecial
      if ( File.exists?(device) && File.ftype(device) == "blockSpecial" )
        my_devices << device
      else
        log "  WARNING: Cannot use device #{device} - skipping"
      end
    else
      break
    end
    dev_index += 1
  end

  # Check if /mnt is actually on a seperate device.
  # ec2 instances and images that do now have ephemeral will be caught by this, eg: t1.micro and HVM
  if my_devices.empty?
    log "  Skipping ephemeral drive setup for non-ephemeral image/instance size"
  else
    # determine mnt_device from root_device name
    mnt_device = current_mnt_device ||
                 case root_device
                 when /sda/
                   "/dev/sdb"
                 when /sde/
                   "/dev/sdf"
                 when /vda/
                   "/dev/vdb"
                 when /xvda/
                   "/dev/xvdb"
                 when /xvde/
                   (node[:platform] == "redhat") ? "/dev/xvdj" : "/dev/xvdf"
                 end

    # Generate fstab entry here
    fstab_entry = "/dev/vg-data/#{lvm_device}\t#{mount_point}\t#{filesystem_type}\t#{options}\t0 0"

    # If mount point is enabled, mount it.
    # This will catch reboots.
    mount mount_point do
      ignore_failure true
      device "/dev/vg-data/#{lvm_device}"
      options options
      fstype filesystem_type
      only_if { File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$") }
    end

    # From here on, not_if checking if entry in fstab and mtab

    # If fstab & mtab entry exists, assume a reboot and skip to end
    # /dev/sdb (/dev/sdf on redhat) is mounted on /mnt on the
    # image by default as an ext3 filesystem. Umount this device
    # so it can be used in the LVM
    mount "/mnt" do
      device mnt_device
      fstype "ext3"
      action [:umount, :disable]
      not_if { ( File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$") ) && ( File.open('/etc/mtab', 'r') { |f| f.read }.match(" #{mount_point} #{filesystem_type} " ) ) }
    end

    # Create the mount point
    directory mount_point do
      owner 'root'
      group 'root'
      mode 0755
      recursive true
      not_if { ( File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$") ) && ( File.open('/etc/mtab', 'r') { |f| f.read }.match(" #{mount_point} #{filesystem_type} " ) ) }
    end

    # Setup the LVM across all ephemeral devices
    ruby_block "LVM setup" do
      block do
        require 'rightscale_tools'

        def run_command(command, ignore_failure = false)
          Chef::Log.info "  Running: #{command}"
          Chef::Log.info `#{command}`
          STDOUT.flush
          raise "command exited non-zero! #{command}" unless ignore_failure || $?.success?
        end

        my_devices.each do |device|
          Chef::Log.info "  Updating device #{device}"
          run_command("pvcreate -ff -y #{device}")
        end

        if my_devices.empty?
          Chef::Log.info "  No ephemeral devices attached"
        else
          run_command("vgcreate vg-data #{my_devices.join(' ')}")
          run_command("lvcreate vg-data -n #{lvm_device} -i #{my_devices.size} -I 256 -l 100%VG")
          run_command("mkfs.#{filesystem_type} /dev/vg-data/#{lvm_device}")

          # Add the fstab_entry to fstab if it does not already exists.
          # Can exists if restart or stop/start
          fstab = File.readlines("/etc/fstab")
          if fstab.include?(fstab_entry + "\n")
            Chef::Log.info "  Device already added to /etc/fstab: #{fstab_entry}"
          else
            File.open("/etc/fstab", "w") do |f|
              fstab.each do |line|
                f.puts(line)
              end
              Chef::Log.info "  ADDING DEVICE /etc/fstab: #{fstab_entry}"
              f.puts(fstab_entry)
            end
          end
          run_command("mount /dev/vg-data/#{lvm_device}")
          Chef::Log.info "Done setting up LVM on ephemeral drives"
        end
      end
      not_if { ( File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$") ) && ( File.open('/etc/mtab', 'r') { |f| f.read }.match(" #{mount_point} #{filesystem_type} " ) ) }
    end
  end
else
  log "  Skipping LVM on ephemeral drives setup for non-ephemeral cloud #{cloud}"
end

rightscale_marker :end
