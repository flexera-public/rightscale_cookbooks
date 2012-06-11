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
  remote_server = new_resource.remote_server
  # Keep the default configuration (local file only logging) unless a
  # remote server is defined.
  if remote_server != ""
    if node[:platform] =~ /redhat|centos/
      # Centos uses an old version of rsyslog that does not by default support
      # using /etc/rsyslog.d.  Instead of maintaining CentOS specific configuration
      # we can just append the remote log line to the end of the existing file.
      # Note this will work with the configuration files that support /etc/rsyslog.d
      # (i.e. centos 6) without removing it.  However once all supportted OS's use
      # /etc/rsyslog.d this should be removed.

      # Skipping if entry already exists in /etc/rsyslog.conf
      log "  Configuring Redhat/CentOS."
      remote_server_string = "\*.info @#{remote_server}:514"
      bash "add remote log server to centos config file" do
        flags "-ex"
        code <<-EOH
          echo "\n#{remote_server_string}\n\n" >> /etc/rsyslog.conf
        EOH
        not_if do ::File.open('/etc/rsyslog.conf', 'r') { |f| f.read }.include? "#{remote_server_string}" end
      end
    else
      log "  Configuring ubuntu."
      template "/etc/rsyslog.d/remote.conf" do
        action :create
        source "rsyslog.d.remote.conf.erb"
        owner "root"
        group "root"
        mode "0644"
        cookbook 'logging_rsyslog'
        variables(
          :remote_server => remote_server
        )
      end
    end
    action_restart
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

