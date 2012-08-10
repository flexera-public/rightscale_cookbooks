# 
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

include RightScale::LB::Helper

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
  template "/etc/haproxy/haproxy.cfg.head" do
    source "haproxy.cfg.head.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    stats_file="stats socket /etc/haproxy/status user haproxy group haproxy"
    variables(
      :stats_file_line => stats_file
    )
  end

  pool_name = new_resource.pool_name
  # Install the haproxy config backend which is the part of the haproxy config that doesn't change.
  template "/etc/haproxy/haproxy.cfg.default_backend" do
    source "haproxy.cfg.default_backend.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backup false
    variables(
       :default_backend_line => "#{pool_name}_backend"
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

  pool_name = new_resource.pool_name

  # Create the directory for vhost server files.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  lb_haproxy_backend  "create main backend section" do
    pool_name  pool_name
    advanced_configs false
  end

  action_advanced_configs

  # (Re)generate the haproxy config file.
  execute "/etc/haproxy/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :run
    notifies :reload, resources(:service => "haproxy")
  end

  # Tag this server as a load balancer for vhost it will answer for so app servers can send requests to it.
  right_link_tag "loadbalancer:#{pool_name}=lb"

end


action :attach do

  pool_name = new_resource.pool_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

    # Create the directory for vhost server files.
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
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


  action_advanced_configs



end

action :advanced_configs do

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  pool_name = new_resource.pool_name
  pool_name_full =  new_resource.pool_name_full
  backend_authorized_users = new_resource.backend_authorized_users
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

  lb_haproxy_backend  "create main backend section" do
    pool_name  pool_name
    advanced_configs false
  end

  # http-request auth section, supported only from haproxy v 1.4
  if backend_authorized_users

    ha_version = %x{/usr/sbin/haproxy -v | grep "version"}
    if ha_version.include?("1.3")
      raise "http-request auth is not available in ths version of HA proxy: #{ha_version}"
    end

    # RESULT EXAMPLE
    # userlist UsersFor__appserver
    # user user1 insecure-password 678
    template "/etc/haproxy/#{node[:lb][:service][:provider]}.d/userlist_backend_#{pool_name}.conf" do
         source "haproxy_backend_userlist.erb"
         owner "haproxy"
         group "haproxy"
         mode 0600
         backup false
         cookbook "lb_haproxy"
         variables(
           :pool_name => pool_name,
           :user_credentials => backend_authorized_users
         )
    end

    # recreate backend section of haproxy config, to add authorization rules for each backend
    # acl Auth__appserver http_auth(UsersFor__appserver)
    # http-request auth realm _appserver if !Auth__appserver
    lb_haproxy_backend  "create main backend section" do
      pool_name  pool_name
      advanced_configs true
    end

    # (Re)generate the haproxy config file.
    execute "/etc/haproxy/haproxy-cat.sh" do
      user "haproxy"
      group "haproxy"
      umask 0077
      action :run
      notifies :reload, resources(:service => "haproxy")
    end

  end

  # Restoring default config if we have dummy value
  directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/dummy" do
    action :delete
    only_if do ::File.open('/etc/haproxy/haproxy.cfg.default_backend', 'r') { |f| f.read }.include? "dummy" end
  end

  template "/etc/haproxy/haproxy.cfg.default_backend" do
    source "haproxy.cfg.default_backend.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    backup false
    variables(
       :default_backend_line => "#{pool_name}_backend"
    )
    only_if do ::File.open('/etc/haproxy/haproxy.cfg.default_backend', 'r') { |f| f.read }.include? "dummy" end
    notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
  end

end


action :attach_request do

  pool_name = new_resource.pool_name

  log "  Attach request for #{new_resource.backend_id} / #{new_resource.backend_ip} / #{pool_name}"

  # Run remote_recipe for each vhost app server wants to be part of.
  remote_recipe "Attach me to load balancer" do
    recipe "lb::handle_attach"
    attributes :remote_recipe => {
      :backend_ip => new_resource.backend_ip,
      :backend_id => new_resource.backend_id,
      :backend_port => new_resource.backend_port,
      :pool_names => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
  end

end


action :detach do

  pool_name = new_resource.pool_name
  backend_id = new_resource.backend_id

  log "  Detaching #{new_resource.backend_id} from #{pool_name}"

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
  file ::File.join("/etc/haproxy/#{node[:lb][:service][:provider]}.d", pool_name, backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
  end


  # After detaching instance from backend pool we must check if that pool is default
  # and if the detached instance was last in that pool
  # if it is true we need to point haproxy to
  # another existing pool or put default value if that pool was last one.
  attached_servers = get_attached_servers(pool_name)
  default_entry = ::File.open('/etc/haproxy/haproxy.cfg.default_backend', 'r') { |f| f.read }.include? "#{pool_name}"
  # We use this conditional because "get_attached_servers" is evaluated before
  # backend_id file deleted, so we just check that resulting set contain only one element
  # and this element is id of detached instance


  if attached_servers.size == 1 and attached_servers.include?(backend_id) and default_entry == true
    # Removing pool store directory
    full_pool_path = "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}"

    directory full_pool_path do
      action :delete
    end

    first_connected_pool = ::File.basename(::Dir["/etc/haproxy/#{node[:lb][:service][:provider]}.d/*"].reject{|o| not (::File.directory?(o) and o != full_pool_path) }.first || "dummy")

    # Create dummy backend section for haproxy correct operations
    if first_connected_pool == "dummy"
      directory "/etc/haproxy/#{node[:lb][:service][:provider]}.d/dummy"

      lb_haproxy_backend  "create dummy backend section" do
        pool_name  "dummy"
        advanced_configs false
      end
    end

    log "  Changing default pool to #{first_connected_pool}"
    template "/etc/haproxy/haproxy.cfg.default_backend" do
      source "haproxy.cfg.default_backend.erb"
      cookbook "lb_haproxy"
      owner "haproxy"
      group "haproxy"
      mode "0400"
      backup false
      variables(
         :default_backend_line => "#{first_connected_pool}_backend"
      )
      only_if do ::File.open('/etc/haproxy/haproxy.cfg.default_backend', 'r') { |f| f.read }.include? "#{pool_name}" end  # not working
      notifies :run, resources(:execute => "/etc/haproxy/haproxy-cat.sh")
    end
  else
    log "  No pools to detach"
  end

end


action :detach_request do

  pool_name = new_resource.pool_name

  log "  Detach request for #{new_resource.backend_id} / #{pool_name}"

  # Run remote_recipe for each vhost app server is part of.
  remote_recipe "Detach me from load balancer" do
    recipe "lb::handle_detach"
    attributes :remote_recipe => {
      :backend_id => new_resource.backend_id,
      :pool_names => pool_name
    }
    recipients_tags "loadbalancer:#{pool_name}=lb"
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
