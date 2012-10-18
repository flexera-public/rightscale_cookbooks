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
  log("WARNING: reload not supported in rsyslog - doing restart") { level :warn }
  action_restart
end


action :configure do

  service "rsyslog" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  if node[:platform_version] =~ /^5\..+/
    # Both CentOS and RedHat 5.8 have rsyslog v3.22 as the latest provided package
    # the IUS repository carries rsyslog v4.8 for these operating systems.
    # Update is needed to support RELP and have all the security updates of the new version.
    # Because YUM cannot remove the rsyslog package without dependencies we use RPM to do that
    package "rsyslog" do
      action :remove
      options "--nodeps"
      ignore_failure true
      provider Chef::Provider::Package::Rpm
    end

    package "rsyslog4" do
      # Confirming new installation of package has started
      notifies :start, resources(:service => "rsyslog"), :immediately
    end

  end

  remote_server = new_resource.remote_server

  # Only configure client server if remote logging server is used.
  unless remote_server.empty?

    package "rsyslog-relp" if node[:logging][:protocol] =~ /relp/

    if node[:logging][:protocol] == "relp+stunnel"
      configure_stunnel "default" do
        accept "127.0.0.1:515"
        connect "#{remote_server}:514"
        client "client = yes"
      end
    end

    # Writing configuration template.
    template value_for_platform(
      ["ubuntu"] => { "default" => "/etc/rsyslog.d/client.conf" },
      ["centos", "redhat"] => { "5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/client.conf" }
    ) do
      action :create
      source "client.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      cookbook "logging_rsyslog"
      variables(
        :remote_server => remote_server
      )
      notifies :restart, resources(:service => "rsyslog"), :immediately
    end

  end

end


action :configure_server do

  # This action would configure an rsyslog logging server.

  service "rsyslog" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  package "rsyslog-relp" if node[:logging][:protocol] =~ /relp/

  configure_stunnel if node[:logging][:protocol] == "relp+stunnel"

  # Need to open a listening port on desired protocol.
  sys_firewall "Open logger listening port" do
    port 514
    protocol node[:logging][:protocol] == "udp" ? "udp" : "tcp"
    enable true
    action :update
  end

  # Writing configuration template.
  template value_for_platform(
    ["ubuntu"] => { "default" => "/etc/rsyslog.d/10-server.conf" },
    ["centos", "redhat"] => { "5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/10-server.conf" }
  ) do
    action :create
    source "server.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    cookbook "logging_rsyslog"
    notifies :restart, resources(:service => "rsyslog"), :immediately
  end

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

