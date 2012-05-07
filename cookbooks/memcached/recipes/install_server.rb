#
# Cookbook Name:: memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rs_utils_marker :begin


## memcached install
if File.exists?("#{node[:memcached][:config_file]}") # to to avoid reinstall after a reboot
    log "    Memcached already installed."
else
    log "    Installing memcached package for #{node[:platform]}"
    package "memcached" do
        action :install
    end
    log "    Installation complete."
end

# initializing supported commands for memcached services for further usage
service "memcached" do
    action :nothing
    persist true
    reload_command "/etc/init.d/memcached force-reload" # had to override because ubuntu doesn't have a "reload" option
    supports :status => true, :start => true, :stop => true, :restart => true, :reload => true
end


## memcached config
log "    Cache size will be set to #{node[:memcached][:memtotal_percent]}% of total system memory : #{node[:memcached][:memtotal]}mb"

# thread input check
if node[:memcached][:threads].to_i < 1
    log "    Number of threads less than 1, using minimum possible"
    node[:memcached][:threads] = "1"
elsif node[:memcached][:threads].to_i  > node[:cpu][:total].to_i
    log "    Number of threads more than #{node[:cpu][:total]}, using maximum available"
    node[:memcached][:threads] = node[:cpu][:total]
end # now user cannot input wrong thread quantity leading to misconfiguration

# listening ip configuration
case node[:memcached][:ip]
    when "localhost"
        node[:memcached][:ip] = "127.0.0.1" # note: not using "localhost" because value also goes into collectd plugin which doesn't understand it
    when "private"
        node[:memcached][:ip] = node[:cloud][:private_ips][0]
    when "public"
        node[:memcached][:ip] = node[:cloud][:public_ips][0]
    when "any"
        node[:memcached][:ip] = "0.0.0.0"
end

# writing settings
template "#{node[:memcached][:config_file]}" do
    source "memcached.conf.erb"
    variables(
            :tcp_port         => node[:memcached][:tcp_port],
            :udp_port         => node[:memcached][:udp_port],
            :user             => node[:memcached][:user],
            :connection_limit => node[:memcached][:connection_limit],
            :memtotal         => node[:memcached][:memtotal],               # calculated option
            :threads          => node[:memcached][:threads],
            :ip               => node[:memcached][:ip],
            :log_level        => node[:memcached][:log_level]
    )
    cookbook 'memcached'
end

service "memcached" do
    action :restart # restart needed for new settings to apply
end # had to move the restart out of the template due to start problem after server reboot

log "    Memcached configuration done."


## firewall configuration
log "    Attention: when using a listening public ip make sure the #{node[:memcached][:tcp_port]} port is open in the firewall (Security Group for EC2)."
log "    Opening port #{node[:memcached][:tcp_port]} in iptables."

sys_firewall "Open memcached port" do
    port node[:memcached][:tcp_port].to_i # port should be passed as int
    enable true
    action :update
end


## checking if memcached actually started
#   problem: when starting memcached on amazon with a public listening ip the daemon doesn't really start though says so
#   there is no interface with public ip on amazon thus you can find
#   "failed to listen on TCP port XXXXX: Cannot assign requested address" in /var/log/memcached.log
#   therefor must use "any ip" aka 0.0.0.0 to listen externally
ruby_block "memcached_check" do
    block do
        # assigning test_ip
        if "#{node[:memcached][:ip]}" == "0.0.0.0"
            test_ip = "#{node[:cloud][:public_ips][0]}" # can't use 0.0.0.0 for TCPSocket
        else
            test_ip = "#{node[:memcached][:ip]}"        # localhost, private, public are ok
        end
        # checking connection
        begin
            TCPSocket.new(test_ip, "#{node[:memcached][:tcp_port]}").close # thus you'll be sure memcached is really running
            Chef::Log.info("    Memcached server started.")
        rescue Errno::ECONNREFUSED
            raise "    Memcached service didn't start."                    # most probably memcached is misconfigured
        end
    end
    action :create
end


## collectd configuration
log "    Configuring collectd memcached plugin."

# memcached.conf plugin
service "collectd" do
    action :stop
end  # need to restart/start after configuration in order for the monitoring to run correctly

ruby_block "process_memcached" do
    block do
        processes = File.readlines("#{node[:rs_utils][:collectd_plugin_dir]}/processes.conf")
        File.open("#{node[:rs_utils][:collectd_plugin_dir]}/processes.conf", "w") do |f|
            processes.each do |line|
                next if line =~ /<\/Plugin>/  # will add memcached process monitoring as last in list regardless of how file may change in the future
                f.puts(line)
            end
            f.puts("  process \"memcached\"")
            f.puts("</Plugin>")
        end
    end
    action :create
end

template "#{node[:rs_utils][:collectd_plugin_dir]}/memcached.conf" do
    source "memcached_collectd.conf.erb"
    variables(
            :ip              => node[:memcached][:ip],
            :tcp_port        => node[:memcached][:tcp_port]
    )
    cookbook 'memcached'
   notifies :start, resources(:service => "collectd"), :immediately # start previously stopped collectd
end

log "    Disabling collectd swap monitoring."

# disable collectd swap
ruby_block "disable_collectd_swap" do
    block do
        collectd = File.readlines("#{node[:rs_utils][:collectd_config]}")
        File.open("#{node[:rs_utils][:collectd_config]}", "w") do |f|
            collectd.each do |line|
                next if line =~ /LoadPlugin swap/  # simply cut out useless line
                f.puts(line)
            end
        end
    end
    action :create
end # memcached server has swap disabled due to the nature of the system

log "    Collectd configuration done."


## log rotation
log "    Generating new logrotatate config for memcached application."

rs_utils_logrotate_app "memcached" do
    cookbook "rs_utils"
    template "logrotate.erb"
    path ["/var/log/memcached.log"]
    frequency "size 10M"
    rotate 4
    create "644 root root"
end # no restarts or anything needed: logrotate is a cron task


rs_utils_marker :end