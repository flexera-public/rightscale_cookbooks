# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include RightScale::LB::Helper

action :install do

  log "  Installing haproxy"

  # Installs haproxy package.
  package "haproxy" do
    action :install
  end

  # Creates haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :enable
  end

  # Installs haproxy config file depending on platform.
  template "/etc/default/haproxy" do
    only_if { node[:platform] == "ubuntu" }
    source "default_haproxy.erb"
    cookbook "lb_haproxy"
    owner "root"
    notifies :restart, resources(:service => "haproxy")
  end

  # Creates /etc/haproxy directory.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Installs script that concatenates individual server files after the haproxy
  # config head into the haproxy config.
  cookbook_file "/etc/haproxy/haproxy-cat.sh" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    source "haproxy-cat.sh"
    cookbook "lb_haproxy"
  end

  # Installs the haproxy config head which is the part of the haproxy config
  # that doesn't change.
  template "/etc/haproxy/haproxy.cfg.head" do
    source "haproxy.cfg.head.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    stats_file="stats socket /etc/haproxy/status user haproxy group haproxy"
    variables(
      :stats_file_line => stats_file,
      :timeout_client => node[:lb_haproxy][:timeout_client]
    )
  end


  # Installs the haproxy config backend which is the part of the haproxy config
  # that doesn't change.
  template "/etc/haproxy/haproxy.cfg.default_backend" do
    source "haproxy.cfg.default_backend.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backup false
    variables(
      :default_backend_line => "#{new_resource.pool_name}_backend"
    )
  end

  # Generates the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    notifies :start, resources(:service => "haproxy")
  end
end


action :add_vhost do

  pool_name = new_resource.pool_name

  # Creates the directory for vhost server files.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Adds current pool to pool_list conf to preserve lb/pools order
  template "/etc/haproxy/#{node[:lb][:service][:provider]}.d/pool_list.conf" do
     source "haproxy_backend_list.erb"
     owner "haproxy"
     group "haproxy"
     mode 0600
     backup false
     cookbook "lb_haproxy"
     variables(
       :pool_list => node[:lb][:pools]
     )
  end

  # See cookbooks/lb_haproxy/definitions/haproxy_backend.rb for the definition
  # of "lb_haproxy_backend".
  lb_haproxy_backend  "create main backend section" do
    pool_name  pool_name
  end

  # Calls the "advanced_configs" action.
  action_advanced_configs

  # (Re)generates the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :run
    notifies :reload, resources(:service => "haproxy")
  end

  # Tags this server as a load balancer for vhost it will answer for so app servers
  # can send requests to it.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
  right_link_tag "loadbalancer:#{pool_name}=lb"

end


action :attach do

  pool_name = new_resource.pool_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Creates haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # Creates the directory for vhost server files.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # (Re)generates the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Creates an individual server file for each vhost and notifies the concatenation script if necessary.
  template ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", pool_name, new_resource.backend_id) do
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

action :advanced_configs do

  # Creates haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  pool_name = new_resource.pool_name
  pool_name_full =  new_resource.pool_name_full
  log "  Current pool name is #{pool_name}"
  log "  Current FULL pool name is #{pool_name_full}"

  # Template to generate acl sections for haproxy config file
  # RESULT EXAMPLE
  # acl url_serverid  path_beg    /serverid
  # acl ns-ss-db1-test-rightscale-com_acl  hdr_dom(host) -i ns-ss-db1.test.rightscale.com
  template "/etc/haproxy/#{node[:lb][:service][:provider]}.d/acl_#{pool_name}.conf" do
     source "haproxy_backend_acl.erb"
     owner "haproxy"
     group "haproxy"
     mode 0600
     backup false
     cookbook "lb_haproxy"
     variables(
       :pool_name => pool_name,
       :pool_name_full => pool_name_full
     )
  end

  # Template to generate acl sections for haproxy config file
  # RESULT EXAMPLE
  # use_backend 2_backend if url_serverid
  template "/etc/haproxy/#{node[:lb][:service][:provider]}.d/use_backend_#{pool_name}.conf" do
    source "haproxy_backend_use.erb"
    owner "haproxy"
    group "haproxy"
    mode 0600
    backup false
    cookbook "lb_haproxy"
    variables(
      :pool_name => pool_name,
      :pool_name_full => pool_name_full
    )
  end

end


action :attach_request do

  pool_name = new_resource.pool_name

  log "  Attach request for #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Runs remote_recipe for each vhost the app server wants to be part of.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RemoteRecipe for the "remote_recipe" resource.
  remote_recipe "Attach me to load balancer" do
    recipe "lb::handle_attach"
    attributes :remote_recipe => {
      :backend_ip => new_resource.backend_ip,
      :backend_id => new_resource.backend_id,
      :backend_port => new_resource.backend_port,
      :pools => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
  end

end


action :detach do

  pool_name = new_resource.pool_name
  backend_id = new_resource.backend_id

  log "  Detaching #{backend_id} from #{pool_name}"

  # Creates haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generates the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Deletes the individual server file and notifies the concatenation script if necessary.
  file ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", pool_name, backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
  end

end


action :detach_request do

  pool_name = new_resource.pool_name

  log "  Detach request for #{new_resource.backend_id} / #{pool_name}"

  # Runs remote_recipe for each vhost the app server is part of.
  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RemoteRecipe for the "remote_recipe" resource.
  remote_recipe "Detach me from load balancer" do
    recipe "lb::handle_detach"
    attributes :remote_recipe => {
      :backend_id => new_resource.backend_id,
      :pools => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
  end

end


action :setup_monitoring do

  log "  Setup monitoring for haproxy"

  # Installs the haproxy collectd script into the collectd library plugins directory.
  cookbook_file(::File.join(node[:rightscale][:collectd_lib], "plugins", "haproxy")) do
    source "haproxy1.4.rb"
    cookbook "lb_haproxy"
    mode "0755"
  end

  # Adds a collectd config file for the haproxy collectd script with the exec plugin and restart collectd if necessary.
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
