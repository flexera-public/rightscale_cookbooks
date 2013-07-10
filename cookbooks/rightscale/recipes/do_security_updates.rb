#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if "#{node[:rightscale][:security_updates]}" == "enable"
  platform =  node[:platform]
  log "  Applying secutiy updates for #{platform}"
  # Make sure we DON'T check the output of the update because it
  # may return a non-zero error code when one server is down but all
  # the others are up, and a partial update was successful!
  # If the upgrade fails then the security update monitor will
  # trigger alerting users to investigate what went wrong.
  case platform
  when "ubuntu"
    execute "apply apt security updates" do
      command "apt-get -y update && apt-get -y upgrade || true"
    end
    ruby_block "check and tag if reboot required" do
      block do
        if ::File.exists?("/var/run/reboot-required")
          execute "rs_tag -a 'rs_monitoring:reboot_required=true'"
        else
          execute "rs_tag -r 'rs_monitoring:reboot_required=true'"
        end
      end
    end
  when "centos", "redhat"
    # Update packages
    current_kernel_version = nil
    ruby_block "obtain current kernel version before update" do
      block do
        uname_cmd = Mixlib::ShellOut.new("uname -r")
        uname_cmd.run_command
        uname_cmd.error!
        current_kernel_version = uname_cmd.stdout.chomp
      end
    end
    execute "apply yum security updates" do
      command "yum -y update || true"
    end
    ruby_block "check and tag if reboot is required" do
      block do
        uname_cmd = Mixlib::ShellOut.new("uname -r")
        uname_cmd.run_command
        uname_cmd.error!
        if uname_cmd.stdout.chomp != current_kernel_version
          execute "rs_tag -a 'rs_monitoring:reboot_required=true'"
        else
          execute "rs_tag -r 'rs_monitoring:reboot_required=true'"
        end
      end
    end
  else
    log " Security updates not supported for platform #{platform}"
  end
else
  log "  Security updates disabled. Skipping update!"
end
