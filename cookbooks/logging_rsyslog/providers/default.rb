#
# Cookbook Name:: logging_rsyslog
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop rsyslog
action :stop do
  service "rsyslog" do
    action :start
    persist false
  end
end


# Start rsyslog
action :start do
  service "rsyslog" do
    action :start
    persist false
  end
end


# Restart rsyslog
action :restart do
  service "rsyslog" do
    action :restart
    persist false
  end
end


# Reload rsyslog
action :reload do
  service "rsyslog" do
    action :reload
    persist false
  end
end


action :install do
  # The replacing syslog-ng with rsyslog requires low level package
  # manipulation via rpm/dpkg
  package "rsyslog"
end


action :configure do

  service "rsyslog" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  remote_server = new_resource.remote_server || ""

  # Keep the default configuration (local file only logging) unless a remote server is defined.
  # will restart syslog only if the the conf file changes
  template value_for_platform(
             ["ubuntu"] => {"default" => "/etc/rsyslog.d/client.conf"},
             ["centos", "redhat"] => {"5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/client.conf"}
           ) do
    action :create
    source "client.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    cookbook "logging_rsyslog"
    not_if { remote_server.empty? }
    variables(
      :remote_server => remote_server
    )
    notifies :restart, resources(:service => "rsyslog"), :immediately
  end
end


action :configure_server do
  # This action would configure an rsyslog logging server.

  # Need to open a listening port on desired protocol.
  sys_firewall "Open logger listening port" do
    port 514
    protocol "udp"
    enable true
    action :update
  end

  # Writing configuration template.
  template value_for_platform(
             ["ubuntu"] => {"default" => "/etc/rsyslog.d/10-server.conf"},
             ["centos", "redhat"] => {"5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/10-server.conf"}
           ) do
    action :create
    source "server.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    cookbook "logging_rsyslog"
  end

  # Restarting service in order to apply new settings.
  action_restart
end


action :rotate do
  raise "Rsyslog action not implemented"
end


action :add_remote_server do
  raise "Rsyslog action not implemented"
end


action :add_definition do
  raise "Rsyslog action not implemented"
end


action :add_rotate_policy do
  raise "Rsyslog action not implemented"
end

