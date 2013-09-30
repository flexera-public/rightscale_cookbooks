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
      # 'subscription-manager' is a client program that registers a system with
      # a subscription management service.
      #
      #   --auto-attach
      # Automatically attaches the best-matched, compatible subscriptions to the
      # system.

      cmd = "subscription-manager register"
      cmd << " --username=#{username} --password=#{password}"
      cmd << " --auto-attach --force"

      subscribe = Mixlib::ShellOut.new(cmd)
      subscribe.run_command
      Chef::Log.info subscribe.stdout
      Chef::Log.info subscribe.stderr unless subscribe.exitstatus == 0
      subscribe.error!

      # 'product-id' and 'subscription-manager' yum plug-ins provide support for
      # the certificate-based Content Delivery Network.
      # Making sure they are enabled.
      [
        "/etc/yum/pluginconf.d/product-id.conf",
        "/etc/yum/pluginconf.d/subscription-manager.conf"
      ].each do |plugin|
        text = File.read(plugin)
        puts = text.gsub(/enabled=0/, "enabled=1")
        File.open(plugin, "w") { |file| file << puts }
      end
    end
  end
end
