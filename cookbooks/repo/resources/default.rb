#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# This lightweight resource only defines the interface for repo providers.  This file
# defines the actions and attributes that make up the repo interface (or abstraction).
# Please see the action details found in the lightweight providers of other implementing
# cookbooks: cookbooks/repo_<provider>/providers/default.rb

# Pull code from a determined repository to a specified destination.
actions :pull
# Pull code from a determined repository to a specified destination and create a capistrano-style deployment.
actions :capistrano_pull
# Setup repository URL and other attributes.
actions :setup_attributes


# Common attributes
#

# Path to where project repo will be pulled
attribute :destination, :kind_of => String

# Repository Url
attribute :repository, :kind_of => String

# Remote repo Branch or revision
attribute :revision, :kind_of => String

# Account name
attribute :account, :kind_of => String

# Account credential
attribute :credential, :kind_of => String

# ROS endpoint
attribute :endpoint, :kind_of => String

# ssh_hostkey to be added to known hosts
attribute :ssh_host_key, :kind_of => String

# SVN
#

# Extra arguments passed to the subversion command
attribute :svn_arguments, :kind_of => String


# ROS
#

# The prefix that will be used to name/locate the backup of a particular code repo.
attribute :prefix, :kind_of => String

# Location where dump file will be saved. Used by dump recipes to back up to Amazon S3 or Rackspace Cloud Files.
attribute :storage_account_provider, :kind_of => String

# The cloud storage location where the dump file will be restored from.
#  For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name.
attribute :container, :kind_of => String

# Unpack downloaded source or not Source file must be kind of tar archive
attribute :unpack_source, :equal_to => [true, false], :default => true


# Capistrano
#

# System user to run the deploy as
attribute :app_user, :kind_of => String

# An array of paths, relative to app root, to be removed from a checkout before symlinking
attribute :purge_before_symlink, :kind_of => Array, :default => %w{}

# Directories to create before symlinking. Runs after purge_before_symlink
attribute :create_dirs_before_symlink, :kind_of => Array, :default => %w{}

# A hash that maps files in the shared directory to their paths in the current release
attribute :symlinks, :kind_of => Hash, :default => ({})

# @group[Capistrano attributes] A hash of the form {"ENV_VARIABLE"=>"VALUE"}
attribute :environment, :kind_of => Hash, :default => ({})
