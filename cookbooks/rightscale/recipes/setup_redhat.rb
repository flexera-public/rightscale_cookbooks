#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

ruby_block "register_redhat_system" do
  not_if { ::File.exists?("/etc/sysconfig/rhn/systemid") }
  block do
    usr = node[:rightscale][:redhat][:username]
    pwd = node[:rightscale][:redhat][:password]
    raise "'rightscale/redhat/username' input must be set!" if usr.to_s.empty?
    raise "'rightscale/redhat/password' input must be set!" if pwd.to_s.empty?

    # 'rhnreg_ks' is a utility for registering a system with the
    # RHN Satellite or Red Hat Network Classic.
    cmd = "rhnreg_ks --username=#{usr} --password=#{pwd}"
    cmd << " --use-eus-channel --force --verbose"

    rhnreg_ks = Mixlib::ShellOut.new(cmd)
    rhnreg_ks.run_command

    # During successful run 'rhnreg_ks' doesn't log any messages.
    # Logs STDOUT and STDERR only if command execution fails.
    unless rhnreg_ks.exitstatus == 0
      log rhnreg_ks.stdout
      log rhnreg_ks.stderr
      rhnreg_ks.error!
    end
  end
end
