#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

SANDBOX_BIN_GEM = "/opt/rightscale/sandbox/bin/gem"

# right_rackspace gem
RACKSPACE_GEM = "right_rackspace"
RACKSPACE_VERSION = "0.0.0.20111110"

# right_cloud_api gem
RIGHT_CLOUD_API_GEM = "right_cloud_api"
RIGHT_CLOUD_API_VERSION = "0.0.0"

# rightscale_tools gem
RS_TOOLS_GEM = "rightscale_tools"
RS_TOOLS_VERSION = "1.5.5"

COOKBOOK_DEFAULT_GEMS = ::File.join(::File.dirname(__FILE__), "..", "files", "default")

# Install tools dependencies

# right_rackspace
r = gem_package "#{COOKBOOK_DEFAULT_GEMS}/#{RACKSPACE_GEM}-#{RACKSPACE_VERSION}.gem" do
  gem_binary SANDBOX_BIN_GEM
  version RACKSPACE_VERSION
  action :nothing
end
r.run_action(:install)

# right_cloud_api
r = gem_package "#{COOKBOOK_DEFAULT_GEMS}/#{RIGHT_CLOUD_API_GEM}-#{RIGHT_CLOUD_API_VERSION}" do
  gem_binary SANDBOX_BIN_GEM
  version RIGHT_CLOUD_API_VERSION
  action :nothing
end
r.run_action(:install)

# Install tools
r = gem_package "#{COOKBOOK_DEFAULT_GEMS}/#{RS_TOOLS_GEM}-#{RS_TOOLS_VERSION}.gem" do
  gem_binary SANDBOX_BIN_GEM
  version RS_TOOLS_VERSION
  action :nothing
end
r.run_action(:install)

Gem.clear_paths

rightscale_marker :end
