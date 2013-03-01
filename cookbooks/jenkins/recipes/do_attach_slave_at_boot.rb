#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if node[:jenkins][:attach_slave_at_boot] == "true"
	log " Attaching to master node at boot..."
  include_recipe "jenkins::do_attach_request"
else
  log "  Attach slave at boot [skipped]"
end

rightscale_marker :end