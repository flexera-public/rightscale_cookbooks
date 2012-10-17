#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

set_unless[:logging][:remote_server] = ""

set[:logging][:cert_dir] = "/etc/stunnel/"

case node[:platform]
when "ubuntu"
  set[:logging][:stunnel_service] = "stunnel4"
when "centos", "redhat"
  set[:logging][:stunnel_service] = "stunnel"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end