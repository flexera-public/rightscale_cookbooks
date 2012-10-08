#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#
set_unless[:monkey][:git][:user] = "arangamani"
set_unless[:monkey][:git][:email] = "kannan@rightscale.com"
set_unless[:monkey][:git][:ssh_key] = "somekey"
set_unless[:monkey][:git][:host_name] = "github.com"

set[:monkey][:rest][:packages] = []
set[:monkey][:rest][:gem_packages] = [
  "rake",
  "bundler",
  "jeweler",
  "ruby-debug",
  "gemedit",
  "diff-lcs",
  "rspec"
]
set[:monkey][:virtualmonkey][:gem_packages] = [
  "rake",
  "hoe",
  "rcov", 
  "fog", 
  "ParseTree",
  "ruby2ruby",
  "chef",
  "daemons",
  "colorize",
  "sinatra",
  "chronic",
  "right_http_connection",
  "right_aws"
]

node[:monkey][:rest][:version] = ""
node[:monkey][:rest][:right_passwd] = "passwd"
node[:monkey][:rest][:right_email] = "email"
node[:monkey][:rest][:right_acct_id] = "2901"
node[:monkey][:rest][:ssh_key] = "somekey"

node[:monkey][:virtualmonkey][:packages] = []
node[:monkey][:virtualmonkey][:version]
node[:monkey][:virtualmonkey][:collateral_repo_url] = 'git@github.com:rightscale/servertemplate_tests.git'
node[:monkey][:virtualmonkey][:environment] = 'testing'
