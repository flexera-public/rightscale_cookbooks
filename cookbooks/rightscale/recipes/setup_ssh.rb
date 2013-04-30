#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if "#{node[:rightscale][:private_ssh_key]}" != ""

  log "  Install private key"

  directory "/root/.ssh" do
    recursive true
  end
  template "/root/.ssh/id_rsa" do
    source "id_rsa.erb"
    mode "0600"
  end

else

  raise "  Private SSH key is empty!"

end

rightscale_marker :end
