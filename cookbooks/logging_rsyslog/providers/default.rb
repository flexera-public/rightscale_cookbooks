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
  # Keep the default configuration (local file only logging) unless a remote server is defined.
  if remote_server != ""

    package "rsyslog-relp" if node[:logging][:protocol] == "relp"

    # Pull the credentials from the inputs into local files for TLS configuration.
    if node[:logging][:protocol] == "tcp+tls"

      package "rsyslog-gnutls"

      # Creating directory where certificate files will be stored
      directory node[:logging][:cert_dir] do
        mode "0700"
        recursive true
      end

      tls_ca_certificate = ::File.join(node[:logging][:cert_dir], "ca.pem")

      template tls_ca_certificate do
        mode "0400"
        cookbook "logging"
        source "tls_ca_certificate.erb"
      end

    end

    if node[:logging][:protocol] == "relp+stunnel"

      package "rsyslog-relp"
      package "stunnel"

      template "/etc/stunnel/client.conf" do
        action :create
        source "stunnel.conf.erb"
        owner "root"
        group "root"
        mode "0644"
        cookbook "logging_rsyslog"
        variables(
          :accept => "127.0.0.1:515",
          :connect => "#{remote_server}:514",
          :client => "client = yes"
        )
      end

      bash "Apply new settings to STunnel" do
        flags "-ex"
        code <<-EOH
          stunnel /etc/stunnel/client.conf
        EOH
      end

    end

    # Writing configuration template.
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
      variables(
        :remote_server => remote_server
      )
    end
  end

  # Restarting service in order to apply new settings.
  action_restart
end


action :configure_server do
  # This action would configure an rsyslog logging server.

  package "rsyslog-relp" if node[:logging][:protocol] == "relp"

  # Pull the credentials from the inputs into local files for TLS configuration.
  if node[:logging][:protocol] == "tcp+tls"

    package "rsyslog-gnutls"

    # Creating directory where certificate files will be stored
    directory node[:logging][:cert_dir] do
      mode "0700"
      recursive true
    end

    tls_ca_certificate = ::File.join(node[:logging][:cert_dir], "ca.pem")
    tls_certificate = ::File.join(node[:logging][:cert_dir], "cert.pem")
    tls_key = ::File.join(node[:logging][:cert_dir], "key.pem")

    template tls_ca_certificate do
      mode "0400"
      cookbook "logging"
      source "tls_ca_certificate.erb"
    end

    template tls_certificate do
      mode "0400"
      cookbook "logging"
      source "tls_certificate.erb"
    end

    template tls_key do
      mode "0400"
      cookbook "logging"
      source "tls_key.erb"
    end

  end

  if node[:logging][:protocol] == "relp+stunnel"

    package "rsyslog-relp"
    package "stunnel"

    # Creating directory where certificate files will be stored
    directory node[:logging][:cert_dir] do
      mode "0700"
      recursive true
    end

    certificate = ::File.join(node[:logging][:cert_dir], "stunnel.pem")

    template certificate do
      mode "0400"
      cookbook "logging"
      source "tls_certificate.erb"
    end

    # If the user doesn't input a certificate we can generate a self-signed one and use it
    bash "Generate key for STunnel" do
      flags "-ex"
      code <<-EOH
        rm #{certificate} && openssl req -new -x509 -days 3650 -nodes -out #{certificate} -keyout #{certificate} -subj "/C=US/ST=CA/L=SB/O=Rightscale/OU=Rightscale/CN=Rightscale/emailAddress=support@rightscale.com"
      EOH
      not_if { node[:logging][:tls_certificate] }
    end

    template "/etc/stunnel/server.conf" do
      action :create
      source "stunnel.conf.erb"
      owner "root"
      group "root"
      mode "0644"
      cookbook "logging_rsyslog"
      variables(
        :accept => "514",
        :connect => "515",
        :cert => "cert = #{certificate}"
      )
    end

    bash "Apply new settings to STunnel" do
      flags "-ex"
      code <<-EOH
        stunnel /etc/stunnel/server.conf
      EOH
    end

  end

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

