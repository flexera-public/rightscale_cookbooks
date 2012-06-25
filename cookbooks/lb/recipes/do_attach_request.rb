# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

vhosts(node[:lb][:vhost_names]).each do |vhost_name|
  log "  Adding tag to answer for vhost load balancing - #{vhost_name}."
  lb_tag vhost_name


    if node[:lb][:advanced_config][:backend_pool_name]
      backend_pool_name = "backend_pool_name=#{node[:lb][:advanced_config][:backend_pool_name]}"
      lb_tag backend_pool_name
    end

    if node[:lb][:advanced_config][:backend_uri_path]
      backend_uri_path = "backend_uri_path=#{node[:lb][:advanced_config][:backend_uri_path]}"
      lb_tag backend_uri_path
    end

    if node[:lb][:advanced_config][:backend_fqdn]
      backend_fqdn = "backend_fqdn=#{node[:lb][:advanced_config][:backend_fqdn]}"
      lb_tag backend_fqdn
    end



  log "  Sending remote attach request..."
  lb vhost_name do
    backend_id node[:rightscale][:instance_uuid]
    backend_ip node[:app][:ip]
    backend_port node[:app][:port].to_i
    service_region node[:lb][:service][:region]
    service_lb_name node[:lb][:service][:lb_name]
    service_account_id node[:lb][:service][:account_id]
    service_account_secret node[:lb][:service][:account_secret]
    action :attach_request
  end
end

rightscale_marker :end
