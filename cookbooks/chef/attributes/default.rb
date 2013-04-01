#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# The Chef client configuration directory
set[:chef][:client][:config_dir] = "/etc/chef"

# Recommended attributes
default[:chef][:client][:version] = "10.24.0-1"
default[:chef][:client][:environment] = "_default"

# Required attributes
default[:chef][:client][:server_url] = ""
default[:chef][:client][:private_ssh_key] = ""
default[:chef][:client][:validation_name] = ""

# Optional attributes
default[:chef][:client][:node_name] = ""
default[:chef][:client][:roles] = ""
