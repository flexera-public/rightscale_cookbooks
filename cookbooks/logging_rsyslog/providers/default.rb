#
# Cookbook Name:: logging_rsyslog
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Stop rsyslog
action :stop do
  service "rsyslog" do
    action :stop
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


# Install rsyslog package
action :install do
  # The replacing syslog-ng with rsyslog requires low level package
  # manipulation via rpm/dpkg
  package "rsyslog"
end


# Configure logging: client side
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

    if node[:logging][:protocol] == "relp-secured"
      # Configures an stunnel used to pass log messages from a client server to a logging server.
      # See cookbooks/logging_rsyslog/definitions/configure_stunnel.rb for "configure_stunnel" definition.
      configure_stunnel "default" do
        accept "127.0.0.1:515"
        connect "#{remote_server}:514"
        client "client = yes"
      end
    end

    # Writing configuration template.
    template value_for_platform(
      ["ubuntu"] => {"default" => "/etc/rsyslog.d/client.conf"},
      ["centos", "redhat"] => {"5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/client.conf"}
    ) do
      source "client.conf.erb"
      cookbook "logging_rsyslog"
      owner "root"
      group "root"
      mode "0644"
      variables(
        :remote_server => remote_server,
        :platform_version => node[:platform_version],
        :logging_protocol => node[:logging][:protocol]
      )
      notifies :restart, resources(:service => "rsyslog"), :immediately
    end

  end

end


# Configure an rsyslog logging server.
action :configure_server do

  service "rsyslog" do
    supports :restart => true, :status => true, :start => true, :stop => true
    action :nothing
  end

  # Installs package to add RELP compatibility for rsyslog
  package "rsyslog-relp" if node[:logging][:protocol] =~ /relp/

  # Configures an stunnel used to pass log messages from a client server to a logging server.
  # See cookbooks/logging_rsyslog/definitions/configure_stunnel.rb for "configure_stunnel" definition.
  configure_stunnel if node[:logging][:protocol] == "relp-secured"

  # Need to open a listening port on desired protocol.
  sys_firewall "Open logger listening port" do
    port 514
    protocol node[:logging][:protocol] == "udp" ? "udp" : "tcp"
    enable true
    action :update
  end

  # Writing configuration template.
  template value_for_platform(
    ["ubuntu"] => {"default" => "/etc/rsyslog.d/10-server.conf"},
    ["centos", "redhat"] => {"5.8" => "/etc/rsyslog.conf", "default" => "/etc/rsyslog.d/10-server.conf"}
  ) do
    source "server.conf.erb"
    cookbook "logging_rsyslog"
    owner "root"
    group "root"
    mode "0644"
    notifies :restart, resources(:service => "rsyslog"), :immediately
    variables(
      :logging_protocol => node[:logging][:protocol]
    )
  end

end


# Call the logging rotate command
action :rotate do
  raise "Rsyslog action not implemented"
end


# Add a remote logging server
action :add_remote_server do
  raise "Rsyslog action not implemented"
end


# Add a logging definition
action :add_definition do
  raise "Rsyslog action not implemented"
end


# Add a logrotate policy
action :add_rotate_policy do
  raise "Rsyslog action not implemented"
end
