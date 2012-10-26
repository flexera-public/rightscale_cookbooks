#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :set_private do
  log "==================== sys_dns(:set_private) CloudDNS BEGIN ==================== "

  # A new instance for CloudDNS class (found in 'cookbooks/sys_dns/libraries/helper.rb') is created
  # and the 'action_set' method is called with proper parameters.
  RightScale::DnsTools::CloudDNS.new(Chef::Log).action_set(new_resource.id, new_resource.user, new_resource.password, new_resource.address, :region => new_resource.region )

  log "==================== sys_dns(:set_private) CloudDNS   END ==================== "
end
