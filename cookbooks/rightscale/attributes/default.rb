#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# RightScale Environment Attributes.
# These are needed by all RightScale Cookbooks.
# rightscale should be included in all server templates so these attributes are declared here.


# Optional attributes

# Timezone
default[:rightscale][:timezone] = "UTC"
# Process list
default[:rightscale][:process_list] = ""
# Process match list
default[:rightscale][:process_match_list] = ""
# Database backup file
default[:rightscale][:db_backup_file] = "/var/run/db-backup"
# Short hostname
default[:rightscale][:short_hostname] = ""
# Domain name
default[:rightscale][:domain_name] = ""
# Domain search suffix
default[:rightscale][:search_suffix] = ""
# Enable/disable security updates
default[:rightscale][:security_update] = "disable"

# Required attributes

# Private SSH key
default[:rightscale][:private_ssh_key] = ""

default[:rightscale][:security_update] = "disable"

# Cloud specific attributes

# Rackspace username
default[:rightscale][:rackspace_username] = ""
# Rackspace Tenant ID
default[:rightscale][:rackspace_tenant_id] = ""
# Rackspace API key
default[:rightscale][:rackspace_api_key] = ""
