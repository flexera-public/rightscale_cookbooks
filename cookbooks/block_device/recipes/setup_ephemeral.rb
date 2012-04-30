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
#
options = "defaults,noatime"
if node[:platform] == "ubuntu"
  options += ",bootwait"
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

mnt_device = current_mnt_device || 
             case root_device
             when /sda/ then "/dev/sdb"
             when /sde/ then "/dev/sdf"
             when /xvda/ then "/dev/xvdb"
             when /xvde/ then (node[:platform] == "redhat") ? "/dev/xvdj" : "/dev/xvdf"
             end

# Generate fstab entry here to check if it already exists
fstab_entry = "/dev/vg-data/#{lvm_device}\t#{mount_point}\t#{filesystem_type}\t#{options}\t0 0"

# Only EC2 is currently supported
if cloud == 'ec2' 

  # if fstab entry exists, assume a reboot and skip to end
  if File.open('/etc/fstab', 'r') { |f| f.read }.match("^#{fstab_entry}$")
    log "Ephemeral entry already exists in fstab"
  else
    # Create init script to activate LVM on start for Ubuntu
    remote_file "/etc/init.d/lvm_activate" do
      only_if { node[:platform] == "ubuntu" }
      source "lvm_activate"
      mode 0744
    end

    link "/etc/rcS.d/S32lvm_activate" do
      only_if { node[:platform] == "ubuntu" }
      to "/etc/init.d/lvm_activate"
    end

    # Load device mapper modules for Ubuntu
    bash "Load device mapper" do
      only_if  { node[:platform] == "ubuntu" }
      flags "-ex"
      code <<-EOH
        modprobe dm_mod
        echo "dm_mod" >> /etc/modules
      EOH
    end

    # /dev/sdb (/dev/sdf on redhat) is mounted on /mnt on the
    # image by default as an ext3 filesystem. Umount this device
    # so it can be used in the LVM
    mount "/mnt" do
      device mnt_device
      fstype "ext3"
      action [:umount, :disable]
    end

    # Create the mount point
    log "  Create #{mount_point}."
    directory mount_point do
      owner 'root'
      group 'root'
      mode 0755
      recursive true
    end

    # Setup the LVM across all ephemeral devices
    ruby_block "LVM setup" do
      block do
        require 'rightscale_tools'

        @api = RightScale::Tools::API.factory('1.0')

        def run_command(command, ignore_failure = false)
          Chef::Log.info "Running: #{command}"
          Chef::Log.info `#{command}`
          STDOUT.flush
          raise "command exited non-zero! #{command}" unless ignore_failure || $?.success?
        end

        # Get a list of ephemeral devices
        # Make sure to skip EBS volumes attached on boot
        my_devices = []
        dev_index = 0
        while (1)
          if node[:ec2][:block_device_mapping]["ephemeral#{dev_index}".to_sym]
            device = node[:ec2][:block_device_mapping]["ephemeral#{dev_index}".to_sym]
            device = '/dev/' + device if device !~ /^\/dev\//
            device = @api.unmap_device_for_ec2(device)
            # verify that device is actually on the instance and is a blockSpecial 
            if ( File.exists?(device) && File.ftype(device) == "blockSpecial" )
              my_devices << device
            else
              Chef::Log.warn "WARNING: Cannot use device #{device} - skipping"
            end
          else
            break
          end
          dev_index += 1
        end

        Chef::Log.info "Found ephemeral devices: #{my_devices}"

        my_devices.each do |device|
          run_command("pvcreate -ff -y #{device}")
        end

        run_command("vgcreate vg-data #{my_devices.join(' ')}")
        run_command("lvcreate vg-data -n #{lvm_device} -i #{my_devices.size} -I 256 -l 60%VG")
        run_command("mkfs.#{filesystem_type} /dev/vg-data/#{lvm_device}")

        # Add the mount to fstab
        fstab = File.readlines("/etc/fstab")
        File.open("/etc/fstab", "w") do |f|
          fstab.each do |line|
            f.puts(line)  
          end
          Chef::Log.info "ADDING DEVICE /etc/fstab: #{fstab_entry}"
          f.puts(fstab_entry)
        end

        run_command("mount /dev/vg-data/#{lvm_device}")
        Chef::Log.info "Done setting up LVM on ephemeral drives"
      end
    end
  end
else
  log "Skipping LVM on ephemeral drives setup for non-EC2 cloud #{cloud}"
end

rightscale_marker :end
