#
# Cookbook Name:: logging_syslog_ng
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# @resource logging

# Stop syslog-ng
action :stop do
  service "syslog-ng" do
    action :stop
    persist false
  end
end

# Start syslog-ng
action :start do
  service "syslog-ng" do
    action :start
    persist false
  end
end

# Restart syslog-ng
action :restart do
  service "syslog-ng" do
    action :restart
    persist false
  end
end

# Reload syslog-ng
action :reload do
  service "syslog-ng" do
    action :reload
    persist false
  end
end

# Install syslog-ng package
action :install do
  # The replacing syslog-ng with rsyslog requires low level package
  # manipulation via rpm/dpkg
  package "syslog-ng"
end

# Configure logging: client side
action :configure do
  remote_server = new_resource.remote_server
  # Keep the default configuration (local file only logging) unless a
  # remote server is defined.
  if remote_server != ""
    template "/etc/syslog-ng/syslog-ng.conf" do
      action :create
      source "syslog-ng.conf.remote.erb"
      owner "root"
      group "root"
      mode "0644"
      cookbook 'logging_syslog_ng'
      variables(
        :remote_server => remote_server
      )
    end
    action_restart
  end
end

# Call the logging rotate command
action :rotate do
  raise "syslog-ng action not implemented"
end

# Add a remote logging server
action :add_remote_server do
  raise "syslog-ng action not implemented"
end

# Add a logging definition
action :add_definition do
  raise "syslog-ng action not implemented"
end

# Add a logrotate policy
action :add_rotate_policy do
  raise "syslog-ng action not implemented"
end
