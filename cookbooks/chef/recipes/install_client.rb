#
# Cookbook Name:: chef
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Copy Chef client installation script from cookbook files.
# Sourced from https://www.opscode.com/chef/install.sh
cookbook_file "/tmp/install.sh" do
  source "install.sh"
  mode "0755"
  cookbook "chef"
end

# Installs the Chef client using user selected version.
execute "/tmp/install.sh -v #{node[:chef][:client][:version]}"

log "  Chef client version #{node[:chef][:client][:version]} installation is" +
    " completed"

# Creates the Chef client configuration, private ssh key and runlist.
include_recipe "chef::do_attach"

rightscale_marker :end
