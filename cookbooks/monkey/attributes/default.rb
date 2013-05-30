#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Required attributes
#

# Fog Credentials

# AWS Access Key ID
set_unless[:monkey][:fog][:aws_access_key_id] = ""
# AWS Secret Access Key
set_unless[:monkey][:fog][:aws_secret_access_key] = ""
# AWS Publish Access Key ID
set_unless[:monkey][:fog][:aws_publish_key] = ""
# AWS Publish Secret Key
set_unless[:monkey][:fog][:aws_publish_secret_key] = ""
# AWS Access Key ID for Test Account
set_unless[:monkey][:fog][:aws_access_key_id_test] = ""
# AWS Secret Access Key for Test Account
set_unless[:monkey][:fog][:aws_secret_access_key_test] = ""
# Rackspace API Key
set_unless[:monkey][:fog][:rackspace_api_key] = ""
# Rackspace Username
set_unless[:monkey][:fog][:rackspace_username] = ""
# Rackspace UK API Key for Test Account
set_unless[:monkey][:fog][:rackspace_api_uk_key_test] = ""
# Rackspace UK Username for Test Account
set_unless[:monkey][:fog][:rackspace_uk_username_test] = ""
# AWS Access Key ID for RS ServerTemplates Account
set_unless[:monkey][:fog][:aws_access_key_id_rstemp] = ""
# AWS Secret Access Key for RS ServerTemplates Account
set_unless[:monkey][:fog][:aws_secret_access_key_rstemp] = ""
# Softlayer API Key
set_unless[:monkey][:fog][:softlayer_api_key] = ""
# Softlayer Username
set_unless[:monkey][:fog][:softlayer_username] = ""
# Rackspace Managed Auth Key
set_unless[:monkey][:fog][:rackspace_managed_auth_key] = ""
# Rackspace Managed Username
set_unless[:monkey][:fog][:rackspace_managed_username] = ""
# Rackspace Managed UK Auth Key for Test Account
set_unless[:monkey][:fog][:rackspace_managed_uk_auth_key] = ""
# Rackspace Managed UK Username for Test Accounr
set_unless[:monkey][:fog][:rackspace_managed_uk_username] = ""
# Rackspace UK Auth URL for Test Account
set_unless[:monkey][:fog][:rackspace_auth_url_uk_test] = ""
# Google Access Key ID
set_unless[:monkey][:fog][:google_access_key_id] = ""
# Google Secret Access Key
set_unless[:monkey][:fog][:google_secret_access_key] = ""
# Azure Access Key ID
set_unless[:monkey][:fog][:azure_access_key_id] = ""
# Azure Secret Access Key
set_unless[:monkey][:fog][:azure_secret_access_key] = ""
# S3 Bucket Name for Reports Storage
set_unless[:monkey][:fog][:s3_bucket] = ""
# Openstack Folsom Access Key ID
set_unless[:monkey][:fog][:openstack_access_key_id] = ""
# Openstack Folsom Secret Access Key
set_unless[:monkey][:fog][:openstack_secret_access_key] = ""
# Openstack Auth URL
set_unless[:monkey][:fog][:openstack_auth_url] = ""
# Rackspace Private Access Key ID
set_unless[:monkey][:fog][:raxprivatev3_access_key_id] = ""
# Rackspace Private Secret Access Key
set_unless[:monkey][:fog][:raxprivatev3_secret_access_key] = ""
# Rackspace Private Auth URL
set_unless[:monkey][:fog][:raxprivatev3_auth_url] = ""
# HP Access Key ID
set_unless[:monkey][:fog][:hp_access_key_id] = ""
# HP Secret Access Key
set_unless[:monkey][:fog][:hp_secret_access_key] = ""
# HP Auth URL
set_unless[:monkey][:fog][:hp_auth_url] = ""

# Git Settings

# Git Username
set_unless[:monkey][:git][:user] = ""
# Git Email
set_unless[:monkey][:git][:email] = ""
# Git SSH Key
set_unless[:monkey][:git][:ssh_key] = ""
# Git Hostname
set_unless[:monkey][:git][:host_name] = ""

# Rest Connection Settings

# RightScale Password
set_unless[:monkey][:rest][:right_passwd] = ""
# RightScale Email
set_unless[:monkey][:rest][:right_email] = ""
# RightScale Account ID
set_unless[:monkey][:rest][:right_acct_id] = ""
# RightScale Subdomain
set_unless[:monkey][:rest][:right_subdomain] = ""
# SSH Key Used by Rest Connection
set_unless[:monkey][:rest][:ssh_key] = ""
# Public Key for allowing connections from
set_unless[:monkey][:rest][:ssh_pub_key] = ""
# Rest Connection Repository URL
set_unless[:monkey][:rest][:repo_url] = ""
# Rest Connection Repository Branch
set_unless[:monkey][:rest][:repo_branch] = ""

# Test Specific Configuration Settings

# Knife PEM Key used by Chef Client Tests
set_unless[:monkey][:test_config][:knife_pem_key] = ""

# VirtualMonkey Settings

# VirtualMonkey Repository URL
set_unless[:monkey][:virtualmonkey][:monkey_repo_url] = ""
# VirtualMonkey Repository Branch
set_unless[:monkey][:virtualmonkey][:monkey_repo_branch] = ""
# Collateral Repository URL
set_unless[:monkey][:virtualmonkey][:collateral_repo_url] = ""
# Collateral Repository Branch
set_unless[:monkey][:virtualmonkey][:collateral_repo_branch] = ""

# RocketMonkey Settings

# RocketMonkey Repository URL
set_unless[:monkey][:rocketmonkey][:repo_url] = ""
# RocketMonkey Repository Branch
set_unless[:monkey][:rocketmonkey][:repo_branch] = ""

# Recommended attributes
#

# Gems required for rest_connection
set_unless[:monkey][:rest][:gem_packages] = [
  {:name => "rake", :version => "10.0.3"},
  {:name => "bundler", :version => "1.2.3"},
  {:name => "jeweler", :version => "1.8.4"},
  {:name => "ruby-debug", :version => "0.10.4"},
  {:name => "gemedit", :version => "1.0.1"},
  {:name => "diff-lcs", :version => "1.1.3"},
  {:name => "rspec", :version => "2.12.0"}
]
# Monkey user
set_unless[:monkey][:user] = "root"
# Monkey user's home directory
set_unless[:monkey][:user_home] = "/root"
# Monkey group
set_unless[:monkey][:group] = "root"
# Rest connection path
set_unless[:monkey][:rest_connection_path] =
  "#{node[:monkey][:user_home]}/rest_connection"
# Virtualmonkey path
set_unless[:monkey][:virtualmonkey_path] =
  "#{node[:monkey][:user_home]}/virtualmonkey"
# Rocketmonkey path
set_unless[:monkey][:rocketmonkey_path] =
  "#{node[:monkey][:user_home]}/rocketmonkey"
# The version for the rubygems-update gem
set_unless[:monkey][:rubygems_update_version] = "1.8.24"

# Optional Attributes

# Azure Hack on/off
set_unless[:monkey][:rest][:azure_hack_on] = ""
# Azure Hack Retry Count
set_unless[:monkey][:rest][:azure_hack_retry_count] = ""
# Azure Hack Sleep Seconds
set_unless[:monkey][:rest][:azure_hack_sleep_seconds] = ""
# API Logging on/off
set_unless[:monkey][:rest][:api_logging] = ""
