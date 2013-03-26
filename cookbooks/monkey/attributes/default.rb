#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Recommended attributes
#

set_unless[:monkey][:rest][:packages] = []
set_unless[:monkey][:rest][:gem_packages] = [
  {:name => "rake", :version => "10.0.3"},
  {:name => "bundler", :version => "1.2.3"},
  {:name => "jeweler", :version => "1.8.4"},
  {:name => "ruby-debug", :version => "0.10.4"},
  {:name => "gemedit", :version => "1.0.1"},
  {:name => "diff-lcs", :version => "1.1.3"},
  {:name => "rspec", :version => "2.12.0"}
]

set_unless[:monkey][:virtualmonkey][:packages] = []
