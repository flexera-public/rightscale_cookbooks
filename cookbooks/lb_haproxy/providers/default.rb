# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :install do

  log "  Installing haproxy"

  # Install haproxy package.
  package "haproxy" do
    action :install
  end

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :enable
  end

  # Install haproxy file depending on OS/platform.
  template "/etc/default/haproxy" do
    only_if { node[:platform] == "debian" || node[:platform] == "ubuntu" }
    source "default_haproxy.erb"
    cookbook "lb_haproxy"
    owner "root"
    notifies :restart, resources(:service => "haproxy")
  end

  # Create /etc/haproxy directory.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Install script that concatenates individual server files after the haproxy config head into the haproxy config.
  cookbook_file "/etc/haproxy/haproxy-cat.sh" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    source "haproxy-cat.sh"
    cookbook "lb_haproxy"
  end

  # Install the haproxy config head which is the part of the haproxy config that doesn't change.
  template "/etc/haproxy/rightscale_lb.cfg.head" do
    source "haproxy_http.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    stats_file="stats socket /etc/haproxy/status user haproxy group haproxy"
    variables(
      :stats_file_line => stats_file
    )
  end

  # Install the haproxy config backend which is the part of the haproxy config that doesn't change.
  template "/etc/haproxy/rightscale_lb.cfg.default_backend" do
    source "haproxy_default_backend.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    default_backend = node[:lb][:vhost_names].gsub(/\s+/, "").split(",").first.gsub(/\./, "_") + "_backend"
    variables(
      :default_backend_line => default_backend
    )
  end

  # Generate the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    notifies :start, resources(:service => "haproxy")
  end
end


action :add_vhost do

  vhost_name = new_resource.vhost_name

  # Create the directory for vhost server files.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{vhost_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Create backend haproxy files for vhost it will answer for.
  template ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", "#{vhost_name}.cfg") do
    source "haproxy_backend.erb"
    cookbook 'lb_haproxy'
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backend_name = vhost_name.gsub(".", "_") + "_backend"
    stats_uri = "stats uri #{node[:lb][:stats_uri]}" unless "#{node[:lb][:stats_uri]}".empty?
    stats_auth = "stats auth #{node[:lb][:stats_user]}:#{node[:lb][:stats_password]}" unless \
                "#{node[:lb][:stats_user]}".empty? || "#{node[:lb][:stats_password]}".empty?
    health_uri = "option httpchk GET #{node[:lb][:health_check_uri]}" unless "#{node[:lb][:health_check_uri]}".empty?
    health_chk = "http-check disable-on-404" unless "#{node[:lb][:health_check_uri]}".empty?
    variables(
      :backend_name_line => backend_name,
      :stats_uri_line => stats_uri,
      :stats_auth_line => stats_auth,
      :health_uri_line => health_uri,
      :health_check_line => health_chk
    )
  end

  # (Re)generate the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :run
    notifies :reload, resources(:service => "haproxy")
  end

  # Tag this server as a load balancer for vhost it will answer for so app servers can send requests to it.
  right_link_tag "loadbalancer:#{vhost_name}=lb"

end


action :attach do

  vhost_name = new_resource.vhost_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Create an individual server file for each vhost and notify the concatenation script if necessary.
  template ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id) do
    source "haproxy_server.erb"
    owner "haproxy"
    group "haproxy"
    mode 0600
    backup false
    cookbook "lb_haproxy"
    variables(
      :backend_name => new_resource.backend_id,
      :backend_ip => new_resource.backend_ip,
      :backend_port => new_resource.backend_port,
      :max_conn_per_server => node[:lb][:max_conn_per_server],
      :session_sticky => new_resource.session_sticky,
      :health_check_uri => node[:lb][:health_check_uri]
    )
    notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
  end

end

action :attach_request do

  vhost_name = new_resource.vhost_name

  log "  Attach request for #{new_resource.backend_id} / #{new_resource.backend_ip} / #{vhost_name}"

  # Run remote_recipe for each vhost app server wants to be part of.
  remote_recipe "Attach me to load balancer" do
    recipe "lb::handle_attach"
    attributes :remote_recipe => {
      :backend_ip => new_resource.backend_ip,
      :backend_id => new_resource.backend_id,
      :backend_port => new_resource.backend_port,
      :vhost_names => vhost_name
    }
    recipients_tags "loadbalancer:#{vhost_name}=lb"
  end

end


action :detach do

  vhost_name = new_resource.vhost_name

  log "  Detaching #{new_resource.backend_id} from #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Delete the individual server file and notify the concatenation script if necessary.
  file ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
  end

end


action :detach_request do

  vhost_name = new_resource.vhost_name

  log "  Detach request for #{new_resource.backend_id} / #{vhost_name}"

  # Run remote_recipe for each vhost app server is part of.
  remote_recipe "Detach me from load balancer" do
    recipe "lb::handle_detach"
    attributes :remote_recipe => {
      :backend_id => new_resource.backend_id,
      :vhost_names => vhost_name
    }
    recipients_tags "loadbalancer:#{vhost_name}=lb"
  end

end


action :setup_monitoring do

  log "  Setup monitoring for haproxy"

  # Install the haproxy collectd script into the collectd library plugins directory.
  cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", "haproxy")) do
    source "haproxy1.4.rb"
    cookbook "lb_haproxy"
    mode "0755"
  end

  # Add a collectd config file for the haproxy collectd script with the exec plugin and restart collectd if necessary.
  template ::File.join(node[:rightscale][:collectd_plugin_dir], "haproxy.conf") do
    backup false
    source "haproxy_collectd_exec.erb"
    notifies :restart, resources(:service => "collectd")
    cookbook "lb_haproxy"
  end

  ruby_block "add_collectd_gauges" do
    block do
      types_file = ::File.join(node[:rightscale][:collectd_share], "types.db")
      typesdb = IO.read(types_file)
      unless typesdb.include?("gague-age") && typesdb.include?("haproxy_sessions")
        typesdb += <<-EOS
          haproxy_sessions current_queued:GAUGE:0:65535, current_session:GAUGE:0:65535
          haproxy_traffic cumulative_requests:COUNTER:0:200000000, response_errors:COUNTER:0:200000000, health_check_errors:COUNTER:0:200000000
          haproxy_status status:GAUGE:-255:255
        EOS
        ::File.open(types_file, "w") { |f| f.write(typesdb) }
      end
    end
  end

end


action :restart do

  log "  Restarting haproxy"

  require 'timeout'

  Timeout::timeout(new_resource.timeout) do
    while true
      `service #{new_resource.name} stop`
      break if `service #{new_resource.name} status` !~ /is running/
      Chef::Log.info "service #{new_resource.name} not stopped; retrying in 5 seconds"
      sleep 5
    end

    while true
      `service #{new_resource.name} start`
      break if `service #{new_resource.name} status` =~ /is running/
      Chef::Log.info "service #{new_resource.name} not started; retrying in 5 seconds"
      sleep 5
    end
  end

end
