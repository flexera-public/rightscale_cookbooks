#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :set_private do
  log "==================== sys_dns(:set_private) DynDNS BEGIN ==================== "

  # Creates an instance of the DynDNS class (found in cookbooks/sys_dns/libraries/helper.rb)
  # and calls the 'action_set' method with proper parameters.
  RightScale::DnsTools::DynDNS.new(Chef::Log).action_set(new_resource.id, new_resource.user, new_resource.password, new_resource.address)

  log "==================== sys_dns(:set_private) DynDNS   END ==================== "
end
