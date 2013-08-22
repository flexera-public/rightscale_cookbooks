#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:rightscale][:collectd_lib] = "/usr/lib64/collectd"
set_unless[:rightscale][:collectd_share] = "/usr/share/collectd"

case platform
when "ubuntu"
  set_unless[:rightscale][:collectd_packages] = ["collectd", "collectd-core", "collectd-utils", "libcollectdclient0"]
  set_unless[:rightscale][:collectd_config] = "/etc/collectd/collectd.conf"
  set_unless[:rightscale][:collectd_plugin_dir] = "/etc/collectd/conf"
when "centos", "redhat"
  set_unless[:rightscale][:collectd_packages] = ["collectd"]
  set_unless[:rightscale][:collectd_config] = "/etc/collectd.conf"
  set_unless[:rightscale][:collectd_plugin_dir] = "/etc/collectd.d"
else
  raise "Unrecognized distro #{node[:platform]} for monitoring attributes , exiting "
end

default[:rightscale][:plugin_list] = ""
default[:rightscale][:plugin_list_array] = [
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
default[:rightscale][:process_list_array] = []
