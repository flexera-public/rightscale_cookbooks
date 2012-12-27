# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

log "  Override load balancer to use HAProxy."
node[:lb][:service][:provider] = "lb_haproxy"

# 2D array of pools
# Example: [["_serverid", "/serverid"], ["_appsever", "/appsever"], ["default", "default"]]
pool_list = node[:lb][:pools].gsub(/\s+/, "").split(",").uniq.map { |pool| [ pool.gsub(/[\/]/, '_'), pool ] }

pool_list.each do |pool_name_short, pool_name_full|
  log "  Setup default load balancer resource for vhost '#{pool_name_short}'."
  log "  load balancer vhost full name is '#{pool_name_full}'."

  # See cookbooks/lb/resources/default.rb for the "lb" resource.
  lb pool_name_short do
    provider "lb_haproxy"
    pool_name_full pool_name_full
    persist true # Stores this resource in node between converges.
    action :nothing
  end
end

rightscale_marker :end
