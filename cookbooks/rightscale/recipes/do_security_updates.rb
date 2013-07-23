#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if node[:rightscale][:security_updates] == "enable"
  platform = node[:platform]
  log "  Applying security updates for #{platform}"
  # Make sure we DON'T check the output of the update because it
  # may return a non-zero error code when one server is down but all
  # the others are up, and a partial update was successful!
  # If the upgrade fails then the security update monitor will
  # trigger alerting users to investigate what went wrong.
  case platform
  when "ubuntu"
    # Update security packages
    execute "apply apt security updates" do
      command "apt-get --yes update && apt-get --yes dist-upgrade"
    end

    # Tags the server if a reboot is required
    ruby_block "check and tag if reboot required" do
      block do
        if ::File.exists?("/var/run/reboot-required")
          Chef::Log.info "  A reboot is required for the security updates to" +
            " take effect. Adding a 'reboot_required' tag to the server."
          # rs_tag command line utility is used instead of the right_link_tag
          # resource as the condition for whether to add or remove the tag is
          # decided inside this ruby block during converge.
          add_tag_cmd = Mixlib::ShellOut.new(
            "rs_tag --add 'rs_monitoring:reboot_required=true'"
          )
          add_tag_cmd.run_command
          Chef::Log.info add_tag_cmd.stdout
          Chef::Log.info add_tag_cmd.stderr unless add_tag_cmd.exitstatus == 0
          add_tag_cmd.error!
        else
          Chef::Log.info "  Reboot is not required after security updates." +
            " Removing the 'reboot_required' tag if present."
          remove_tag_cmd = Mixlib::ShellOut.new(
            "rs_tag --remove 'rs_monitoring:reboot_required=true'"
          )
          remove_tag_cmd.run_command
          Chef::Log.info remove_tag_cmd.stdout
          Chef::Log.info remove_tag_cmd.stderr \
            unless remove_tag_cmd.exitstatus == 0
          remove_tag_cmd.error!
        end
      end
    end
  when "centos"
    # Update security packages
    execute "apply yum security updates" do
      command "yum --assumeyes --security update"
    end

    # Checks if a reboot is required after security updates.
    # CentOS doesn't notify if reboot is required after updates so the active
    # kernel version is compared against the recently installed kernel version.
    ruby_block "check and tag if reboot is required" do
      block do
        uname_cmd = Mixlib::ShellOut.new("uname -r")
        uname_cmd.run_command
        uname_cmd.error!
        active_kernel_version = uname_cmd.stdout.chomp
        Chef::Log.info "  Active kernel version: #{active_kernel_version}"

        rpm_cmd = Mixlib::ShellOut.new("rpm --query kernel | tail -1")
        rpm_cmd.run_command
        rpm_cmd.error!
        recently_installed_kernel_version =
          rpm_cmd.stdout.chomp.split("kernel-")[1]
        Chef::Log.info "  Recently installed kernel version:" +
          " #{recently_installed_kernel_version}"

        # The Google cloud is skipped in this kernel version checking as custom
        # kernels are not supported on this cloud yet. On all other clouds, if
        # the active kernel version is different from the newly installed
        # kernel version, a reboot is required for the new kernel to take
        # effect. A tag 'reboot_required=true' is added if a reboot is required
        # and this tag is removed after the reboot.
        provider = node[:cloud][:provider]
        if provider == "google"
          Chef::Log.info "  Custom kernel upgrades are not supported on cloud" +
            " provider: #{provider}. Skipping kernel version checking..."
        else
          if recently_installed_kernel_version != active_kernel_version
            Chef::Log.info "  New version of kernel is installed during" +
              " security update. Reboot required for this version to become" +
              " active. Adding a 'reboot_required' tag to the server."

            add_tag_cmd = Mixlib::ShellOut.new(
              "rs_tag --add 'rs_monitoring:reboot_required=true'"
            )
            add_tag_cmd.run_command
            Chef::Log.info add_tag_cmd.stdout
            Chef::Log.info add_tag_cmd.stderr unless add_tag_cmd.exitstatus == 0
            add_tag_cmd.error!
          else
            Chef::Log.info "  Currently active kernel is up-to-date. Removing" +
              " the 'reboot_required' tag if present."
            remove_tag_cmd = Mixlib::ShellOut.new(
              "rs_tag --remove 'rs_monitoring:reboot_required=true'"
            )
            remove_tag_cmd.run_command
            Chef::Log.info remove_tag_cmd.stdout
            Chef::Log.info remove_tag_cmd.stderr \
              unless remove_tag_cmd.exitstatus == 0
            remove_tag_cmd.error!
          end
        end
      end
    end
  else
    log "  Security updates not supported for platform #{platform}"
  end
else
  log "  Security updates disabled. Skipping update!"
end
