#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

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
set[:monkey][:rest][:version] = ""

set[:monkey][:virtualmonkey][:packages] = []
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
set[:monkey][:virtualmonkey][:version] = ""
