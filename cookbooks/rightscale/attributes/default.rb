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
default[:rightscale][:timezone] = "UTC"
default[:rightscale][:process_list] = ""
default[:rightscale][:process_match_list] = ""
default[:rightscale][:private_ssh_key] = ""

default[:rightscale][:db_backup_file] = "/var/run/db-backup"

default[:rightscale][:short_hostname] = nil
default[:rightscale][:domain_name] = ""
default[:rightscale][:search_suffix] = ""

default[:rightscale][:security_update] = "Disabled"

# Cloud specific attributes
#
