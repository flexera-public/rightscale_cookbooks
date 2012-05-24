#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:rightscale][:collectd_lib] = "/usr/lib64/collectd"
set_unless[:rightscale][:collectd_share] = "/usr/share/collectd"

case platform
  when "ubuntu", "debian"
    set_unless[:rightscale][:collectd_packages] = ["collectd", "collectd-core", "collectd-utils", "libcollectdclient0"]
    set_unless[:rightscale][:collectd_packages_version] = "4.10.1-2"
    set_unless[:rightscale][:collectd_config] = "/etc/collectd/collectd.conf"
    set_unless[:rightscale][:collectd_plugin_dir] = "/etc/collectd/conf"
  when "centos", "redhat"
    set_unless[:rightscale][:collectd_packages] = ["collectd"]
    set_unless[:rightscale][:collectd_config] = "/etc/collectd.conf"
    set_unless[:rightscale][:collectd_plugin_dir] = "/etc/collectd.d"
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

default[:rightscale][:plugin_list] = ""
default[:rightscale][:plugin_list_ary] = [
  "cpu",
  "df",
  "disk",
  "load",
  "memory",
  "processes",
  "swap",
  "users",
  "ping"
]

default[:rightscale][:process_list] = ""
default[:rightscale][:process_list_ary] = []
