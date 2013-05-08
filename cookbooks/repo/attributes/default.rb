#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Recommended attributes

# Repository URL/ROS container
default[:repo][:default][:repository] = ""
# Repository Branch/Tag/Commit
default[:repo][:default][:revision] = "master"
# Repository provider
default[:repo][:default][:provider] = "repo_git"
# Repository account name
default[:repo][:default][:account] = ""
# Repository account credential
default[:repo][:default][:credential] = ""

# Optional attributes

# Known hosts SSH key
default[:repo][:default][:ssh_host_key] = ""
# Default action to perform
default[:repo][:default][:perform_action] = "pull"
# Default destination to place code
default[:repo][:default][:destination] = "/home/webapps"
# ROS Storage account provider
default[:repo][:default][:storage_account_provider] = ""
# ROS prefix
default[:repo][:default][:prefix] = ""


default[:repo][:default][:environment]= {}
default[:repo][:default][:symlinks]= {}
default[:repo][:default][:purge_before_symlink] = %w{}
default[:repo][:default][:create_dirs_before_symlink] = %w{}
