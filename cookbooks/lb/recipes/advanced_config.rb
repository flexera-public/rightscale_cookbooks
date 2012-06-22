# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# This is dev version
# Need optimizing

#class Chef::Recipe
#  include RightScale::App::Helper
#  include RightScale::LB::Helper
#end

# this trigger will allow advanced configuration
# in :attach action
node[:lb][:advanced_configuration]= true

=begin
# set advanced attributes
vhosts(node[:lb][:vhost_names]).each do |vhost_name|

  # Obtain current list from lb config file.
  inconfig_servers = get_attached_servers(vhost_name)
  log "  Currently attached: #{inconfig_servers.nil? ? 0 : inconfig_servers.count}"

  deployment_servers = query_appservers(vhost_name)
  servers_to_attach = Set.new(deployment_servers.keys) - inconfig_servers

  servers_to_attach.each do |uuid|
    lb vhost_name do
      backend_fqdn deployment_servers[uuid][:backend_fqdn]
      pool_name deployment_servers[uuid][:pool_name]
      backend_url_path deployment_servers[uuid][:backend_url_path]
      action :nothing
    end
  end

end
=end

rightscale_marker :end
