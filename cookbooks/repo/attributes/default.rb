#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

default[:repo][:default][:repository] = ""
default[:repo][:default][:revision] = "HEAD"
default[:repo][:default][:provider] = "repo_git"
default[:repo][:default][:account] = ""
default[:repo][:default][:credential] = ""
default[:repo][:default][:storage_account_provider] = "S3"
default[:repo][:default][:environment]= {}
default[:repo][:default][:symlinks]= {}
default[:repo][:default][:purge_before_symlink] = %w{}
default[:repo][:default][:create_dirs_before_symlink] = %w{}
default[:repo][:default][:perform_action] = :pull
default[:repo][:default][:prefix] = ""
default[:repo][:default][:endpoint] = ""
