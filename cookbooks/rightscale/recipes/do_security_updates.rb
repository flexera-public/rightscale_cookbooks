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
      command "apt-get -y update && apt-get -y dist-upgrade || true"
    end
    ruby_block "check and tag if reboot required" do
      block do
        if ::File.exists?("/var/run/reboot-required")
          Chef::Log.info "A reboot is required for the security updates to" +
            " take effect. Adding a 'reboot_required' tag to the server"
          add_tag_cmd = Mixlib::ShellOut.new(
            "rs_tag -a 'rs_monitoring:reboot_required=true'"
          )
          add_tag_cmd.run_command
          add_tag_cmd.error!
          Chef::Log.info add_tag_cmd.stdout
        else
          Chef::Log.info "Reboot is not required after security updates." +
            " Removing the 'reboot_required' tag if present"
          remove_tag_cmd = Mixlib::ShellOut.new(
            "rs_tag -r 'rs_monitoring:reboot_required=true'"
          )
          remove_tag_cmd.run_command
          remove_tag_cmd.error!
          Chef::Log.info remove_tag_cmd.stdout
        end
      end
    end
  when "centos", "redhat"
    # Update security packages
    execute "apply yum security updates" do
      command "yum -y update || true"
    end
    # Checking if a reboot is required after security updates.
    # CentOS/RedHat doesn't notify if reboot is required after updates. So
    # check if a new version of kernel is installed, and add a tag for
    # reboot if the active kernel version is different from recently
    # installed kernel version. This check doesn't apply to Google cloud
    # where custom kernels are not supported yet.
    ruby_block "check and tag if reboot is required" do
      block do
        uname_cmd = Mixlib::ShellOut.new("uname -r")
        uname_cmd.run_command
        uname_cmd.error!
        active_kernel_version = uname_cmd.stdout.chomp
        Chef::Log.info "Active kernel version: #{active_kernel_version}"

        rpm_cmd = Mixlib::ShellOut.new("rpm -q kernel | tail -1")
        rpm_cmd.run_command
        rpm_cmd.error!
        recently_installed_kernel_version =
          rpm_cmd.stdout.chomp.split("kernel-")[1]
        Chef::Log.info "Recently installed kernel version:" +
          " #{recently_installed_kernel_version}"

        unless node[:cloud][:provider] == "google"
          if recently_installed_kernel_version != active_kernel_version
            Chef::Log.info "New version of kernel is installed during security" +
              " update. Reboot required for this version to become active." +
              " Adding a 'reboot_required' tag to the server"
            add_tag_cmd = Mixlib::ShellOut.new(
              "rs_tag -a 'rs_monitoring:reboot_required=true'"
            )
            add_tag_cmd.run_command
            add_tag_cmd.error!
            Chef::Log.info add_tag_cmd.stdout
          else
            Chef::Log.info "Currently active kernel is up-to-date. Removing" +
              " the 'reboot_required' tag if present."
            remove_tag_cmd = Mixlib::ShellOut.new(
              "rs_tag -r 'rs_monitoring:reboot_required=true'"
            )
            remove_tag_cmd.run_command
            remove_tag_cmd.error!
            Chef::Log.info remove_tag_cmd.stdout
          end
        end
      end
    end
  else
    log " Security updates not supported for platform #{platform}"
  end
else
  log "  Security updates disabled. Skipping update!"
end
