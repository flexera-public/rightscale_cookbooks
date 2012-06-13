#
# Cookbook Name::memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# memcached install
#
package "memcached" do
  action :install
end

# initializing supported commands for memcached services for further usage
service "memcached" do
  action :enable # we need the service to autostart after reboot
  persist true
  reload_command "/etc/init.d/memcached force-reload" # had to override because ubuntu doesn't have a "reload" option
  supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end


# memcached config
#
# based on the "memcached/memtotal_percent" input this calculates the amount of memory memcached will be using
node[:memcached][:memtotal] = (((node[:memcached][:memtotal_percent].to_i/100.0)*node[:memory][:total].to_i)/1024.0).to_i

log "  Cache size will be set to #{node[:memcached][:memtotal_percent]}% of total system memory : #{node[:memcached][:memtotal]}mb"

# thread input check
if node[:memcached][:threads].to_i < 1
  log "  Number of threads less than 1, using minimum possible"
  node[:memcached][:threads] = "1"
elsif node[:memcached][:threads].to_i > node[:cpu][:total].to_i
  log "  Number of threads more than #{node[:cpu][:total]}, using maximum available"
  node[:memcached][:threads] = node[:cpu][:total]
end # now user cannot input wrong thread quantity leading to misconfiguration

# listening ip configuration
case node[:memcached][:interface]
when "localhost"
  node[:memcached][:interface] = "127.0.0.1" # note: not using "localhost" because value also goes into collectd plugin which doesn't understand it
when "private"
  node[:memcached][:interface] = node[:cloud][:private_ips][0] # when binding to private on aws you also listen to public because of amazons traffic forwarding
when "any"
  node[:memcached][:interface] = "0.0.0.0"
end

# writing settings
template "#{node[:memcached][:config_file]}" do
  source "memcached.conf.erb"
  variables(
    :tcp_port => node[:memcached][:tcp_port],
    :udp_port => node[:memcached][:udp_port],
    :user => node[:memcached][:user],
    :connection_limit => node[:memcached][:connection_limit],
    :memtotal => node[:memcached][:memtotal], # calculated option
    :threads => node[:memcached][:threads],
    :interface => node[:memcached][:interface],
    :log_level => node[:memcached][:log_level]
  )
  cookbook "memcached"
  notifies :restart, resources(:service => "memcached"), :immediately # restart needed for new settings to apply
end

log "  Memcached configuration done."


# firewall configuration
#
log "  Attention: when using a listening public ip make sure the #{node[:memcached][:tcp_port]} port is open in the firewall (Security Group for EC2)."
log "  Opening port #{node[:memcached][:tcp_port]} in iptables."

sys_firewall "Open memcached port" do
  port node[:memcached][:tcp_port].to_i # port should be passed as int
  enable true
  action :update
end


# checking if memcached actually started
#   problem: when trying to start memcached on a closed listening port the daemon doesn't really start though says so
#  "failed to listen on TCP port XXXXX: Cannot assign requested address" @ /var/log/memcached.log
#   any other wrong configured entry might also cause this behaviour so this check is useful
ruby_block "memcached_check" do
  block do
    # test ip configuration
    if "#{node[:memcached][:interface]}" == "0.0.0.0"
      node[:memcached][:check_ip] = "127.0.0.1" # can't run TCPSocket with 0.0.0.0
    else
      node[:memcached][:check_ip] = node[:memcached][:interface]
    end
    begin
      TCPSocket.new("#{node[:memcached][:check_ip]}", "#{node[:memcached][:tcp_port]}").close # thus you'll be sure memcached is really running
      Chef::Log.info("  Memcached server started.")
    rescue Errno::ECONNREFUSED
      raise "  Memcached service didn't start." # most probably memcached is misconfigured
    end
  end
  action :create
end


# collectd configuration
#
log "  Configuring collectd memcached plugin."

# memcached.conf plugin
ruby_block "process_memcached" do
  block do
    processes = File.readlines("#{node[:rightscale][:collectd_plugin_dir]}/processes.conf")
    File.open("#{node[:rightscale][:collectd_plugin_dir]}/processes.conf", "w") do |f|
      processes.each do |line|
        next if line =~ /<\/Plugin>/ # will add memcached process monitoring as last in list regardless of how file may change in the future
        f.puts(line)
      end
      f.puts("  process \"memcached\"")
      f.puts("</Plugin>")
    end
  end
  action :create
end

template "#{node[:rightscale][:collectd_plugin_dir]}/memcached.conf" do
  source "memcached_collectd.conf.erb"
  variables(
    :interface => node[:memcached][:interface],
    :tcp_port => node[:memcached][:tcp_port]
  )
  cookbook "memcached"
  notifies :restart, resources(:service => "collectd"), :immediately # need to restart/start after configuration in order for the monitoring to run correctly
end

log "  Disabling collectd swap monitoring."

# disable collectd swap
ruby_block "disable_collectd_swap" do
  block do
    collectd = File.readlines("#{node[:rightscale][:collectd_config]}")
    File.open("#{node[:rightscale][:collectd_config]}", "w") do |f|
      collectd.each do |line|
        next if line =~ /LoadPlugin swap/ # simply cut out useless line
        f.puts(line)
      end
    end
  end
  action :create
end # memcached server has swap disabled due to the nature of the system

log "  Collectd configuration done."


# log rotation
#
log "  Generating new logrotatate config for memcached application."

rightscale_logrotate_app "memcached" do
  cookbook "rightscale"
  template "logrotate.erb"
  path ["/var/log/memcached.log"]
  frequency "size 10M"
  rotate 4
  create "644 root root"
end # no restarts or anything needed: logrotate is a cron task

rightscale_marker :end
