# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
  include RightScale::LB::Helper
end

DROP_THRESHOLD = 3

# Iterate thru each vhost
vhosts(node[:lb][:vhost_names]).each do | vhost_name |

  log "Attach all for [#{vhost_name}]"
  # Obtain current list from lb config file.
  inconfig_servers = get_attached_servers(vhost_name)
  log "  Currently attached: #{inconfig_servers.nil? ? 0 : inconfig_servers.count}"

  # Obtain list of app servers in deployment.
  deployment_servers = query_appservers(vhost_name)

  # Send warning if no application servers are found.
  log "  No application servers found" do
    only_if { deployment_servers.empty? }
    level :warn
  end

  # Add any servers in deployment not in config.
  servers_to_attach = Set.new(deployment_servers.keys) - inconfig_servers
  log "  No servers to attach" do
    only_if { servers_to_attach.empty? }
  end
  servers_to_attach.each do |uuid|
    lb vhost_name do
      backend_id uuid
      backend_ip deployment_servers[uuid]
      backend_port 8000
      action :attach
    end
  end

  # Increment threshold counter if servers in config not in deployment
  node[:lb][:threshold] ||= Hash.new
  node[:lb][:threshold][vhost_name] ||= Hash.new
  servers_missing = inconfig_servers - Set.new(deployment_servers.keys)
  servers_missing.each do |uuid|
    node[:lb][:threshold][vhost_name][uuid].is_a?(Integer) ? node[:lb][:threshold][vhost_name][uuid] += 1 : node[:lb][:threshold][vhost_name][uuid] = 1
    log "  Increment threshold counter for #{uuid} = #{node[:lb][:threshold][vhost_name][uuid]}"
  end

  # Set threshold counters to nil to those not incremented, thus assuming app server now accessable
  # set to nil since chef does not delete the key, can only alter it
  (Set.new(node[:lb][:threshold][vhost_name].keys)-servers_missing).each do |uuid|
    if node[:lb][:threshold][vhost_name][uuid]
      node[:lb][:threshold][vhost_name][uuid] = nil
      log "  Resetting threshold for #{uuid}"
    end
  end

  # Delete servers that hit threshold
  app_servers_detached = 0
  node[:lb][:threshold][vhost_name].each do |uuid,counter|
    if counter == nil
      next
    elsif counter >= DROP_THRESHOLD
      log "  Threshold of #{DROP_THRESHOLD} reached for #{uuid} (#{node[:lb][:threshold][vhost_name][uuid]}) - detaching"
      lb vhost_name do
        backend_id uuid
        action :detach
      end
      node[:lb][:threshold][vhost_name][uuid] = nil # set to nil - chef does not delete the key, can only alter it.
      app_servers_detached += 1
    else
      log "  Threshold not reached for #{uuid} : #{node[:lb][:threshold][vhost_name][uuid]}"
    end
  end

  log "  No servers to detach" do
    only_if { app_servers_detached == 0 }
  end

end

rightscale_marker :end

