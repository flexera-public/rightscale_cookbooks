#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

case platform
  when "ubuntu", "debian"
    set_unless[:rightscale][:collectd_packages] = ["collectd", "collectd-core", "collectd-utils", "libcollectdclient0"]
    set_unless[:rightscale][:collectd_packages_version] = "4.10.1-2"
  when "centos", "redhat"
    set_unless[:rightscale][:collectd_packages] = ["collectd"]
    case platform_version
    when /5\..+/
      set_unless[:rightscale][:collectd_packages_version] = "4.10.0-4.el5"
      set_unless[:rightscale][:collectd_remove_existing] = true
    when /6\..+/
      set_unless[:rightscale][:collectd_packages_version] = "4.10.7-1.el6"
    end
  else
    raise "Unrecognized distro #{node[:platform]} for monitoring attributes , exiting "
end