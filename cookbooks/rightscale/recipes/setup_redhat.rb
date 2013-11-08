#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

ruby_block "register_redhat_system" do
  block do
    username = node[:rightscale][:redhat][:username]
    password = node[:rightscale][:redhat][:password]

    if username.to_s.empty? || password.to_s.empty?
      message = "  Skipping system registration with Red Hat:"
      message << " In order to run the registration process both"
      message << " 'rightscale/redhat/username' and"
      message << " 'rightscale/redhat/password' inputs should be set."
      Chef::Log.info message

    else
      if node[:cloud][:provider] == "ec2"
        Chef::Log.info "  Registering the system using 'rhnreg_ks'."

        # 'rhnreg_ks' is a utility for registering a system with the
        # RHN Satellite or Red Hat Network Classic.
        cmd = "rhnreg_ks --username=#{username} --password=#{password}"
        cmd << " --use-eus-channel --force --verbose"

        rhnreg_ks = Mixlib::ShellOut.new(cmd)
        rhnreg_ks.run_command

        # During successful run 'rhnreg_ks' doesn't log any messages.
        # Logs STDOUT and STDERR only if command execution fails.
        unless rhnreg_ks.exitstatus == 0
          Chef::Log.info rhnreg_ks.stdout
          Chef::Log.info rhnreg_ks.stderr
        end
        rhnreg_ks.error!

      else
        Chef::Log.info "  Registering the system using 'subscription-manager'."

        # 'subscription-manager' is a client program that registers a system
        # with a subscription management service.
        #
        #   --auto-attach
        # Automatically attaches the best-matched, compatible subscriptions to
        # the system.
        #   --force
        # Regenerates the identity certificate for the system using
        # username/password authentication.

        cmd = "subscription-manager register"
        cmd << " --username=#{username} --password=#{password}"
        cmd << " --auto-attach --force"

        subscribe = Mixlib::ShellOut.new(cmd)
        subscribe.run_command
        Chef::Log.info subscribe.stdout
        Chef::Log.info subscribe.stderr unless subscribe.exitstatus == 0
        subscribe.error!

        # 'product-id' and 'subscription-manager' yum plug-ins provide support
        # for the certificate-based Content Delivery Network.
        # We need to make sure they are enabled.
        [
          "/etc/yum/pluginconf.d/product-id.conf",
          "/etc/yum/pluginconf.d/subscription-manager.conf"
        ].each do |plugin|
          if File.exists?(plugin)
            text = File.read(plugin)
            puts = text.gsub(/enabled=0/, "enabled=1")
            File.open(plugin, "w") { |file| file << puts }
          else
            Chef::Log.info "  WARNING: yum plugin '#{plugin}' not found!"
          end
        end
      end
    end
  end
end
