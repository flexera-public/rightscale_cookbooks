#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

swap_size = node[:sys][:swap_size]
swap_file = node[:sys][:swap_file]

# Sanitize user data 'swap_size'.
if swap_size !~ /^\d*[.]?\d+$/
  raise "  ERROR: invalid swap size."
else
  # Convert swap_size from GB to MB.
  swap_size = ((swap_size.to_f)*1024).to_i
end

# Sanitize user data 'swap_file'.
if swap_file !~ /^\/{1}(((\/{1}\.{1})?[a-zA-Z0-9 ]+\/?)+(\.{1}[a-zA-Z0-9]{2,4})?)$/
  raise "  ERROR: invalid swap file name"
end

# Disable swap if size provided == 0
if swap_size == 0
  # Turn off swap on swap_file if turned on.
  bash 'deactivate swapfile' do
    flags "-ex"
    only_if { File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? }
    code <<-eof
      swapoff #{swap_file}
    eof
  end

  # Remove swap from /etc/fstab
  mount '/dev/null' do
    action :disable
    device "#{swap_file}"
  end

  # Delete swap_file if it exists.
  file "#{swap_file}" do
    only_if { File.exists?(swap_file) }
    backup false
    action :delete
  end

else

  # Check and create swap file
  fs_size_threshold_percent = 75
  swap_dir=File.dirname(swap_file)
  directory swap_dir do
    recursive true
    action :create
    not_if { swap_dir == '/' }
  end

  # If swap file exists and it is not the size requested, deactivate, disable, and delete it to be recreated.
  bash 'validate existing swapfile' do
    flags '-ex'
    not_if { File.exists?(swap_file) && File.stat(swap_file).size/1048576 == swap_size }
    code <<-eof
      swapoff #{swap_file}
    eof
  end
  # Remove swap from /etc/fstab if swapoff
  mount '/dev/null' do
    not_if { File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? }
    action :disable
    device "#{swap_file}"
  end
  # Delete file if no longer in use as swap
  file "#{swap_file}" do
    not_if { File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? }
    backup false
    action :delete
  end

  # Check if enough space is available to create the swap file if it does not already exist.
  ruby_block 'check swap space threshold' do
    block do
      (fs_total, fs_used) = `df --block-size=1M -P #{swap_dir} |tail -1| awk '{print $2":"$3}'`.chomp.split(":")
      if (((fs_used.to_f + swap_size).to_f/fs_total.to_f)*100).to_i > fs_size_threshold_percent
        raise "  ERROR: Requested swap file size is too big! Currently #{fs_used}MB used out of #{fs_total}MB total. Cannot add #{swap_size}MB swap because it would exceed #{fs_size_threshold_percent}% of filesystem."
      end
    end
    not_if { File.exists?(swap_file) }
  end

  # Create swap file if it does not already exist.
  bash 'create swapfile' do
    flags '-ex'
    not_if { File.exists?(swap_file) }
    code <<-eof
      dd if=/dev/zero of=#{swap_file} bs=1M count=#{swap_size}
      chmod 600 #{swap_file}
    eof
  end

  # set file as swap, and turn swap on if not already.
  bash 'activate swapfile' do
    not_if { File.open('/proc/swaps').grep(/^#{swap_file}\b/).any? }
    flags "-ex"
    code <<-eof
      mkswap #{swap_file}
      swapon #{swap_file}
    eof
  end

  # Add swap to /etc/fstab
  mount '/dev/null' do
    action :enable
    device "#{swap_file}"
    fstype 'swap'
    options 'noauto'
  end

  # Activate collectd swap monitoring plugin
  #
  # Add the collectd swap plugin to the set of collectd plugins if it isn't already there
  rightscale_enable_collectd_plugin 'swap'
  # Rebuild the collectd configuration file if necessary
  include_recipe "rightscale::setup_monitoring"
end
