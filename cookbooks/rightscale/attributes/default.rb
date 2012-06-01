#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# RightScale Environment Attributes.
# These are needed by all RightScale Cookbooks.
# rightscale should be included in all server templates so these attributes are declared here.


# Optional attributes
#
set_unless[:rightscale][:timezone] = "UTC"
set_unless[:rightscale][:process_list] = ""
set_unless[:rightscale][:process_match_list] = ""
set_unless[:rightscale][:private_ssh_key] = ""

set_unless[:rightscale][:db_backup_file] = "/var/run/db-backup"

#
# Setup Distro dependent variables
#
case platform
when "redhat","centos","fedora","suse"
  rightscale[:logrotate_config] = "/etc/logrotate.d/syslog"
when "debian","ubuntu"
  rightscale[:logrotate_config] = "/etc/logrotate.d/syslog-ng"
end

default[:rightscale][:short_hostname]        = nil
default[:rightscale][:domain_name]           = ""
default[:rightscale][:search_suffix]         = ""


# Cloud specific attributes
#
