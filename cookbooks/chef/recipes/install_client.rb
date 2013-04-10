#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Copy Chef Client installation script from cookbook files.
# Sourced from https://www.opscode.com/chef/install.sh
cookbook_file "/tmp/install.sh" do
  source "install.sh"
  mode "0755"
  cookbook "chef"
end

# Installs the Chef Client using user selected version.
execute "/tmp/install.sh -v #{node[:chef][:client][:version]}"

log "  Chef Client version #{node[:chef][:client][:version]} installation is" +
  " completed."

rightscale_marker :end
