#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

default[:rightscale][:plugin_list] = ""
default[:rightscale][:plugin_list_array] = [
  "cpu",
  "df",
  "disk",
  "load",
  "memory",
  "processes",
  "users"
]

default[:rightscale][:process_list] = ""
default[:rightscale][:process_list_array] = []

default[:rightscale][:collectd_share] = "/usr/share/collectd"

platform = node[:platform]
case platform
when "ubuntu"
  default[:rightscale][:collectd_packages] = [
    "collectd",
    "collectd-core",
    "collectd-utils",
    "libcollectdclient0"
  ]
  default[:rightscale][:collectd_config] = "/etc/collectd/collectd.conf"
  default[:rightscale][:collectd_plugin_dir] = "/etc/collectd/conf"
  default[:rightscale][:collectd_lib] = "/usr/lib/collectd"
when "centos", "redhat"
  default[:rightscale][:collectd_packages] = ["collectd"]
  default[:rightscale][:collectd_config] = "/etc/collectd.conf"
  default[:rightscale][:collectd_plugin_dir] = "/etc/collectd.d"
  default[:rightscale][:collectd_lib] = "/usr/lib64/collectd"
else
  raise "'#{platform}' platform is not supported yet."
end
