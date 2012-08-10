#
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Adds a port to the apache listen ports.conf file and node attribute
# The node[:apache][:listen_ports] is an array of strings for the webserver to listen on.
# Update this array with the provided port unless it already exists in the array.
# Then update the apache port.conf file. If the ports are already configured correctly
# nothing happens.

define :lb_haproxy_backend, :pool_name => "", :advanced_configs=> false do

  backend_name = params[:pool_name].gsub(".", "_") + "_backend"
  stats_uri = "stats uri #{node[:lb][:stats_uri]}" unless "#{node[:lb][:stats_uri]}".empty?
  stats_auth = "stats auth #{node[:lb][:stats_user]}:#{node[:lb][:stats_password]}" unless \
              "#{node[:lb][:stats_user]}".empty? || "#{node[:lb][:stats_password]}".empty?
  health_uri = "option httpchk GET #{node[:lb][:health_check_uri]}" unless "#{node[:lb][:health_check_uri]}".empty?
  health_chk = "http-check disable-on-404" unless "#{node[:lb][:health_check_uri]}".empty?

  userlist_pool_name = params[:advanced_configs] ? "#{params[:pool_name]}" : ""

  # Create backend haproxy files for vhost it will answer for.
  template ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", "#{params[:pool_name]}.cfg") do
    source "haproxy_backend.erb"
    cookbook 'lb_haproxy'
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backup false
    variables(
      :userlist_pool_name => userlist_pool_name,
      :backend_name_line => backend_name,
      :stats_uri_line => stats_uri,
      :stats_auth_line => stats_auth,
      :health_uri_line => health_uri,
      :health_check_line => health_chk
    )
  end
end