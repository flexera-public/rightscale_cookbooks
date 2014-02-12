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
    end
  end
end
