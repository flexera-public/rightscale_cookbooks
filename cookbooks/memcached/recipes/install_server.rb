#
# Cookbook Name::memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing server tags
#
# The instance is identified as a memcached server.
right_link_tag "memcached_server:active=true"
# The server name so that sorts can be done to get the correct order across app servers.
right_link_tag "memcached_server:uuid=#{node[:rightscale][:instance_uuid]}"
# The instance is associated with a cluster
right_link_tag "memcached_server:cluster=#{node[:memcached][:cluster_id]}"
# The listening port
right_link_tag "memcached_server:port=#{node[:memcached][:tcp_port]}"

log "  Server tags installed."

# Memcached installation.
#
package "memcached" do
  action :install
end

# Initializing supported commands for memcached services for further usage.
service "memcached" do
  # We need the service to autostart after reboot.
  action :enable
  persist true
  supports :status => true, :start => true, :stop => true, :restart => true
end


# Memcached configuration.
#
# Based on the "memcached/memtotal_percent" input this calculates the amount of memory memcached will be using.
node[:memcached][:memtotal] = (((node[:memcached][:memtotal_percent].to_i / 100.0) * node[:memory][:total].to_i) / 1024.0).to_i

log "  Cache size will be set to #{node[:memcached][:memtotal_percent]}% of total system memory : #{node[:memcached][:memtotal]}mb"

# Checking the memcached/threads input to avoid server misconfiguration.
if node[:memcached][:threads].to_i < 1
  log "  Number of threads less than 1, using minimum possible"
  node[:memcached][:threads] = "1"
elsif node[:memcached][:threads].to_i > node[:cpu][:total].to_i
  log "  Number of threads more than #{node[:cpu][:total]}, using maximum available"
  node[:memcached][:threads] = node[:cpu][:total]
end

# Listening ip configuration.
case node[:memcached][:interface]
when "localhost"
  # Note: not using "localhost" because value also goes into collectd plugin which doesn't understand it.
  node[:memcached][:interface] = "127.0.0.1"
when "private"
  # When binding to private on aws you also listen to public because of amazons traffic forwarding.
  node[:memcached][:interface] = node[:cloud][:private_ips][0]
when "any"
  node[:memcached][:interface] = "0.0.0.0"
end

# Logging output level
log_level = ""
case node[:memcached][:log_level]
when "verbose"
  log_level = "-v"
when "debug"
  log_level = "-vv"
when "extremely verbose"
  log_level = "-vvv"
end

# Writing settings to memcached configuration template.
template value_for_platform(
  "ubuntu" => {
    "default" => "/etc/memcached.conf"
  },
  ["centos", "redhat"] => {
    "default" => "/etc/sysconfig/memcached"
  }
) do
  source "memcached.conf.erb"
  variables(
    :tcp_port => node[:memcached][:tcp_port],
    :udp_port => node[:memcached][:udp_port],
    :user => node[:memcached][:user],
    :connection_limit => node[:memcached][:connection_limit],
    :memtotal => node[:memcached][:memtotal],
    :threads => node[:memcached][:threads],
    :interface => node[:memcached][:interface],
    :log_level => log_level
  )
  cookbook "memcached"
  # Restart needed for new settings to apply.
  notifies :restart, resources(:service => "memcached"), :immediately
end

log "  Memcached configuration done."


# Doing firewall configuration.
#
log "  Attention: when using a listening public ip make sure the #{node[:memcached][:tcp_port]} port is open in the firewall (Security Group for EC2)."
log "  Opening port #{node[:memcached][:tcp_port]} in iptables."

sys_firewall "Open memcached port" do
  port node[:memcached][:tcp_port].to_i
  enable true
  action :update
end


# Checking if memcached actually started
#   problem: when trying to start memcached on a closed listening port the daemon doesn't really start though says so
#  "failed to listen on TCP port XXXXX: Cannot assign requested address" @ /var/log/memcached.log
#   Any other wrong configured entry might also cause this behaviour so this check is useful.
ruby_block "memcached_check" do
  block do
    # Test ip configuration.
    if "#{node[:memcached][:interface]}" == "0.0.0.0"
      # Can't run TCPSocket with 0.0.0.0
      check_ip = "127.0.0.1"
    else
      check_ip = node[:memcached][:interface]
    end
    begin
      # Thus you'll be sure memcached is really running.
      TCPSocket.new(check_ip, "#{node[:memcached][:tcp_port]}").close
      Chef::Log.info("  Memcached server started.")
    rescue Errno::ECONNREFUSED
      # Most probably memcached is misconfigured.
      raise "  Memcached service didn't start."
    end
  end
  action :create
end


# Collectd configuration.
#
log "  Configuring collectd memcached plugin."

# Writing settings to memcached.conf plugin.
rightscale_monitor_process "memcached"

template "#{node[:rightscale][:collectd_lib]}/memcached_listener_plugin" do
  source "memcached_listen_disabled_num_plugin.erb"
  mode "0755"
  variables(
    :tcp_port => node[:memcached][:tcp_port]
  )
  cookbook "memcached"
end

template "#{node[:rightscale][:collectd_plugin_dir]}/memcached.conf" do
  source "memcached_collectd.conf.erb"
  variables(
    :interface => node[:memcached][:interface],
    :tcp_port => node[:memcached][:tcp_port],
    :user => node[:memcached][:user],
    :location => "#{node[:rightscale][:collectd_lib]}/memcached_listener_plugin",
    :uuid => node[:rightscale][:instance_uuid]
  )
  cookbook "memcached"
  # Need to restart/start after configuration in order for the monitoring to run correctly.
  notifies :restart, resources(:service => "collectd"), :immediately
end

log "  Collectd configuration done."


# Setting up log rotation: no restarts or anything needed: logrotate is a cron task.
#
log "  Generating new logrotatate config for memcached application."

rightscale_logrotate_app "memcached" do
  cookbook "rightscale"
  template "logrotate.erb"
  path ["/var/log/memcached.log"]
  frequency "size 10M"
  rotate 4
  create "644 root root"
end

rightscale_marker :end
