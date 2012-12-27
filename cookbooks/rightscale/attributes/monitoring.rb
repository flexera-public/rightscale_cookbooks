#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

case platform
when "ubuntu"
  default[:rightscale][:collectd_packages] = ["collectd", "collectd-core", "collectd-utils", "libcollectdclient0"]
  default[:rightscale][:collectd_config] = "/etc/collectd/collectd.conf"
  default[:rightscale][:collectd_plugin_dir] = "/etc/collectd/conf"
  case platform_version
  when /^10\..+/
    default[:rightscale][:collectd_packages_version] = "4.10.1-2"
  when /^12\..+/
    default[:rightscale][:collectd_lib] = "/usr/lib/collectd"
  end
when "centos", "redhat"
  default[:rightscale][:collectd_packages] = ["collectd"]
  default[:rightscale][:collectd_config] = "/etc/collectd.conf"
  default[:rightscale][:collectd_plugin_dir] = "/etc/collectd.d"
  case platform_version
  when /^5\..+/
    default[:rightscale][:collectd_packages_version] = "4.10.0-4.el5"
    default[:rightscale][:collectd_remove_existing] = true
  end
else
  raise "Unrecognized distro #{node[:platform]} for monitoring attributes , exiting "
end

default[:rightscale][:collectd_packages_version] = "latest"
default[:rightscale][:collectd_lib] = "/usr/lib64/collectd"
default[:rightscale][:collectd_share] = "/usr/share/collectd"

default[:rightscale][:plugin_list] = ""
default[:rightscale][:plugin_list_array] = [
  "cpu",
  "df",
  "disk",
  "load",
  "memory",
  "processes",
  "users",
  "ping"
]

default[:rightscale][:process_list] = ""
default[:rightscale][:process_list_array] = []
