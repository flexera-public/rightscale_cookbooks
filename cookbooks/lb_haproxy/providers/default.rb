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

  # Create /home/lb directory.
  directory "/home/lb/#{node[:lb][:service][:provider]}.d" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Install script that concatenates individual server files after the haproxy config head into the haproxy config.
  cookbook_file "/home/lb/haproxy-cat.sh" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    source "haproxy-cat.sh"
    cookbook "lb_haproxy"
  end

  # Install the haproxy config head which is the part of the haproxy config that doesn't change.
  template "/home/lb/rightscale_lb.cfg.head" do
    source "haproxy_http.erb"
    cookbook "lb_haproxy"
    owner "haproxy"
    group "haproxy"
    mode "0400"
    stats_file="stats socket /home/lb/status user haproxy group haproxy"
    variables(
      :stats_file_line => stats_file
    )
  end

  # Install the haproxy config head which is the part of the haproxy config that doesn't change.
  template "/home/lb/rightscale_lb.cfg.default_backend" do
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
  execute "/home/lb/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    notifies :start, resources(:service => "haproxy")
  end

  # Remove haproxy config file so we can symlink it.
  file "/etc/haproxy/haproxy.cfg" do
    backup false
    not_if { ::File.symlink?("/etc/haproxy/haproxy.cfg") }
    action :delete
  end

  # Symlink haproxy config.
  link "/etc/haproxy/haproxy.cfg" do
    to "/home/lb/rightscale_lb.cfg"
  end

end # action :install do

action :add_vhost do

  vhost_name = new_resource.vhost_name

  # Create the directory for vhost server files.
  directory "/home/lb/#{node[:lb][:service][:provider]}.d/#{vhost_name}" do
    owner "haproxy"
    group "haproxy"
    mode 0755
    recursive true
    action :create
  end

  # Create backend haproxy files for vhost it will answer for.
  template ::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", "#{vhost_name}.cfg") do
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
  execute "/home/lb/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :run
    notifies :reload, resources(:service => "haproxy")
  end

  # Tag this server as a load balancer for vhost it will answer for so app servers can send requests to it.
  right_link_tag "loadbalancer:#{vhost_name}=lb"

end # action :add_vhost do

action :attach do

  vhost_name = new_resource.vhost_name

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip} / #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/home/lb/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Create an individual server file for each vhost and notify the concatenation script if necessary.
  template ::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id) do
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
    notifies :run, resources(:execute => "/home/lb/haproxy-cat.sh")
  end

  ## APP TAGs WILL BE
  # lb: fqdn
  # lb: url_path
  # lb: pool_name

  ### INPUTS WILL BE
  # acl_type - path_beg, hdr_dom(host),
  # use_backend_condition -> if
  #, or, and
  #


  ###ACL -> template
  # acl url_serverid  path_beg    /serverid
  #
  # acl ns-ss-db1-test-rightscale-com_acl
  # hdr_dom(host)
  #-i ns-ss-db1.test.rightscale.com



end # action :attach do

action :advanced_configs do
  advanced_rule_directory = "/home/lb/#{node[:lb][:service][:provider]}.d/advanced_configs"
  # create directory where advanced rules configs will be stored
  directory "#{advanced_rule_directory}"

  # create template which will contain advanced acl rules
  #
  ## TEMPLATE EXAMPLE
  # if (lb:fqdn) and (node[:lb][:advanced_config][:acl_condition] == "hdr_dom(host)")
  #  "acl #{new_resource.backend_fqdn}_acl hdr_dom(host) -i #{new_resource.backend_fqdn}"
  # end
  #>>>>  acl ns-ss-db1-test-rightscale-com_acl  hdr_dom(host) -i ns-ss-db1.test.rightscale.com
  # TODO add template file
  template ::File.join("#{advanced_rule_directory}", vhost_name, "acls") do
    source "haproxy_advanced_acl.erb"
    owner "haproxy"
    group "haproxy"
    mode 0600
    backup false
    cookbook "lb_haproxy"
    variables(
      # TODO add resource attributes
      :backend_fqdn => new_resource.backend_fqdn,
      :backend_url_path => new_resource.backend_url_path,
      # TODO add input
      :acl_condition => node[:lb][:advanced_config][:acl_condition]
    )
  end


  ### USE_BACKEND CASE
  # use_backend 2_backend if url_serverid
  # use_backend 2_backend if ns-ss-db2-test-rightscale-com_acl
  #
  # use_backend 1_backend
  # if ns-ss-db1-test-rightscale-com_acl
  #


  # 1  how we will create "1_backend" config file
  # CODE DRAFT EXAMPLE
  # if (lb: pool_name)
  # echo "::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id)" >> "advanced_rule_directory/#{lb:pool_name}"
  # end
  # RESULT EXAMPLE
  # >>>> 1_backend.conf
  # server 01-0F16VI5 10.85.149.59:8000 cookie 01-0F16VI5 check inter 3000 rise 2 fall 3 maxconn 500
  # server 01-2UD17HR 10.40.23.216:8000 cookie 01-2UD17HR check inter 3000 rise 2 fall 3 maxconn 500
  # >>>>

  bash "Creating server pool configs" do
    flags "-ex"
    # TODO  put lb:pool_name value from tag to new_resource.pool_name
    #
    # this script will allow to create pools which can contain more then one app server
    code <<-EOH
    echo "#{::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id)}" >> "#{advanced_rule_directory}/#{new_resource.pool_name}"
    EOH
  end


  # 2  how we will create "/home/lb/haproxy.d/advanced_configs/use_backend.conf"
  #
  # CODE DRAFT EXAMPLE
  # use_backend #{lb:pool_name} node[:lb][:advanced_config][:use_backend_condition] ns-ss-db1-test-rightscale-com_acl
  # RESULT EXAMPLE
  # use_backend 1_backend if ns-ss-db1-test-rightscale-com_acl


  bash "Creating use_backend rule configs" do
     flags "-ex"

     # this script will allow to create pools which can contain more then one app server
     code <<-EOH
     $condition= "use_backend #{new_resource.pool_name} if #{new_resource.backend_fqdn}_acl"
     echo condition >>
echo "#{::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id)}" >> "#{advanced_rule_directory}/#{new_resource.pool_name}"
     EOH
   end

  template ::File.join("#{advanced_rule_directory}", vhost_name, "use_backend.conf") do
    source "haproxy_advanced_use_backend_conf.erb"
    owner "haproxy"
    group "haproxy"
    mode 0600
    backup false
    cookbook "lb_haproxy"
    variables(
     :pool_name => new_resource.pool_name,
     :use_backend_condition => node[:lb][:advanced_config][:use_backend_condition],
     :acl => "#{new_resource.backend_fqdn}_acl"
    )
  end


  # backend_pull template
  # basing on vhost TAG add it to backend pool
  # will create /haproxy.d/pool_* files which will contain groups of host entries


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

end # action :attach_request do

action :detach do

  vhost_name = new_resource.vhost_name

  log "  Detaching #{new_resource.backend_id} from #{vhost_name}"

  # Create haproxy service.
  service "haproxy" do
    supports :reload => true, :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # (Re)generate the haproxy config file.
  execute "/home/lb/haproxy-cat.sh" do
    user "haproxy"
    group "haproxy"
    umask 0077
    action :nothing
    notifies :reload, resources(:service => "haproxy")
  end

  # Delete the individual server file and notify the concatenation script if necessary.
  file ::File.join("/home/lb/#{node[:lb][:service][:provider]}.d", vhost_name, new_resource.backend_id) do
    action :delete
    backup false
    notifies :run, resources(:execute => "/home/lb/haproxy-cat.sh")
  end

end # action :detach do

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

end # action :detach_request do

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
        typesdb += "\nhaproxy_sessions        current_queued:GAUGE:0:65535, current_session:GAUGE:0:65535\nhaproxy_traffic         cumulative_requests:COUNTER:0:200000000, response_errors:COUNTER:0:200000000, health_check_errors:COUNTER:0:200000000\nhaproxy_status          status:GAUGE:-255:255\n"
        ::File.open(types_file, "w") { |f| f.write(typesdb) }
      end
    end
  end

end # action :setup_monitoring do

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

end # action :restart do
