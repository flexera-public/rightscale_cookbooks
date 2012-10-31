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

# Iterates through each vhost.
# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:lb][:pools]).each do |pool_name|

  log "Attach all for [#{pool_name}]"
  # Obtains current list from lb config file.
  # See cookbooks/lb/libraries/helper.rb for the "get_attached_servers" method.
  inconfig_servers = get_attached_servers(pool_name)
  log "  Currently attached: #{inconfig_servers.nil? ? 0 : inconfig_servers.count}"

  # Obtains list of app servers in deployment.
  # See cookbooks/lb/libraries/helper.rb for the "query_appservers" method.
  deployment_servers = query_appservers(pool_name)

  # Sends warning if no application servers are found.
  log "  No application servers found" do
    only_if { deployment_servers.empty? }
    level :warn
  end

  # Adds any servers in deployment not in config.
  servers_to_attach = Set.new(deployment_servers.keys) - inconfig_servers
  log "  No servers to attach" do
    only_if { servers_to_attach.empty? }
  end
  servers_to_attach.each do |uuid|
    # See cookbooks/lb_<provider>/providers/default.rb for the "attach" action.
    lb pool_name do
      backend_id uuid
      backend_ip deployment_servers[uuid][:ip]
      backend_port deployment_servers[uuid][:backend_port].to_i
      session_sticky node[:lb][:session_stickiness]
      action :attach
    end
  end

  # Increments threshold counter if servers in config not in deployment.
  node[:lb][:threshold] ||= Hash.new
  node[:lb][:threshold][pool_name] ||= Hash.new
  servers_missing = inconfig_servers - Set.new(deployment_servers.keys)
  servers_missing.each do |uuid|
    node[:lb][:threshold][pool_name][uuid].is_a?(Integer) ? node[:lb][:threshold][pool_name][uuid] += 1 : node[:lb][:threshold][pool_name][uuid] = 1
    log "  Increment threshold counter for #{uuid} = #{node[:lb][:threshold][pool_name][uuid]}"
  end

  # Sets threshold counters to nil to those not incremented, thus assuming
  # the application server is now accessible. The threshold is set to nil since
  # chef does not delete the key so we can only alter it.
  (Set.new(node[:lb][:threshold][pool_name].keys) - servers_missing).each do |uuid|
    if node[:lb][:threshold][pool_name][uuid]
      node[:lb][:threshold][pool_name][uuid] = nil
      log "  Resetting threshold for #{uuid}"
    end
  end

  # Deletes servers that hit threshold.
  app_servers_detached = 0
  node[:lb][:threshold][pool_name].each do |uuid, counter|
    if counter == nil
      next
    elsif counter >= DROP_THRESHOLD
      log "  Threshold of #{DROP_THRESHOLD} reached for #{uuid} (#{node[:lb][:threshold][pool_name][uuid]}) - detaching"
      # See cookbooks/lb_<provider>/providers/default.rb for the "detach" action.
      lb pool_name do
        backend_id uuid
        action :detach
      end
      node[:lb][:threshold][pool_name][uuid] = nil # Sets to nil since chef does not delete the key so we can only alter it.
      app_servers_detached += 1
    else
      log "  Threshold not reached for #{uuid} : #{node[:lb][:threshold][pool_name][uuid]}"
    end
  end

  log "  No servers to detach" do
    only_if { app_servers_detached == 0 }
  end

end

rightscale_marker :end

