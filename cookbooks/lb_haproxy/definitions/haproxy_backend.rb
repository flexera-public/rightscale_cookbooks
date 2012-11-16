#
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :lb_haproxy_backend, :pool_name => "" do

  backend_name = params[:pool_name] + "_backend"
  stats_uri = "stats uri #{node[:lb][:stats_uri]}" unless "#{node[:lb][:stats_uri]}".empty?
  stats_auth = "stats auth #{node[:lb][:stats_user]}:#{node[:lb][:stats_password]}" unless \
              "#{node[:lb][:stats_user]}".empty? || "#{node[:lb][:stats_password]}".empty?
  health_uri = "option httpchk GET #{node[:lb][:health_check_uri]}" unless "#{node[:lb][:health_check_uri]}".empty?
  health_chk = "http-check disable-on-404" unless "#{node[:lb][:health_check_uri]}".empty?

  # Creates backend haproxy files for the vhost it will answer for.
  template ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", "backend_#{params[:pool_name]}.conf") do
    source "haproxy_backend.erb"
    cookbook 'lb_haproxy'
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backup false
    variables(
      :backend_name_line => backend_name,
      :stats_uri_line => stats_uri,
      :stats_auth_line => stats_auth,
      :health_uri_line => health_uri,
      :health_check_line => health_chk,
      :algorithm => node[:lb_haproxy][:algorithm],
      :timeout_server => node[:lb_haproxy][:timeout_server]
    )
  end
end
