#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

username = node[:rightscale][:redhat][:username]
password = node[:rightscale][:redhat][:password]

if username.to_s.empty? || password.to_s.empty?
  message = "  Skipping system registration with Red Hat:"
  message << " In order to run the registration process both"
  message << " 'rightscale/redhat/username' and"
  message << " 'rightscale/redhat/password' inputs should be set."
  log message

else
  if node[:cloud][:provider] == "ec2"
    log "  Registering the system using 'rhnreg_ks'."

    # 'rhnreg_ks' is a utility for registering a system with the
    # RHN Satellite or Red Hat Network Classic.
    cmd = "rhnreg_ks --username=#{username} --password=#{password}"
    cmd << " --use-eus-channel --force --verbose"

    rhnreg_ks = Mixlib::ShellOut.new(cmd)
    rhnreg_ks.run_command

    # During successful run 'rhnreg_ks' doesn't log any messages.
    # Logs STDOUT and STDERR only if command execution fails.
    unless rhnreg_ks.exitstatus == 0
      log rhnreg_ks.stdout
      log rhnreg_ks.stderr
    end
    rhnreg_ks.error!

  else
    log "  Registering the system using 'subscription-manager'."

    # 'subscription-manager' is a client program that registers a system
    # with a subscription management service.
    #
    #   --auto-attach : Automatically attaches the best-matched, compatible
    #                   subscriptions to the system.
    #
    #   --force : Regenerates the identity certificate for the system using
    #             username/password authentication.
    #
    # On stop/start the system gets a different IP, and registration to
    # Red Hat records all this info. Without re-registration the information
    # would be out of sync.

    cmd = "subscription-manager register"
    cmd << " --username=#{username} --password=#{password}"
    cmd << " --auto-attach --force"

    subscribe = Mixlib::ShellOut.new(cmd)
    subscribe.run_command
    log subscribe.stdout
    log subscribe.stderr unless subscribe.exitstatus == 0
    subscribe.error!

    # 'product-id' and 'subscription-manager' yum plug-ins provide support
    # for the certificate-based Content Delivery Network.
    # We need to make sure they are enabled.
    [
      "/etc/yum/pluginconf.d/product-id.conf",
      "/etc/yum/pluginconf.d/subscription-manager.conf"
    ].each do |plugin_file|
      if File.exists?(plugin_file)
        file_content = File.read(plugin_file)
        if file_content.gsub!(/enabled=0/, "enabled=1")
          log "  Updating #{plugin_file}"
          File.open(plugin_file, "w") { |f| f.write(file_content) }
        end
      else
        log "  WARNING: yum plugin '#{plugin}' not found!"
      end
    end
  end
end
