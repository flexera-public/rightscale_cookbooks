#
# Cookbook Name:: logging_rsyslog
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# This definition configures an stunnel used to pass log messages from a
# client server to a logging server. This solution provides data encryption
# with an SSL certificate provided by user input. As stunnel is configured with
# the "verify = 3" option the server requires and verifies the client
# certificate against the locally installed certificate providing client
# authentication.
#
define :configure_stunnel,
  :accept => "514",
  :connect => "515",
  :client => nil do

  raise "  ERROR: SSL Certificate input is not set. This input is required" +
    " to establish secure connection." if node[:logging][:certificate].empty?

  # Installing stunnel
  package "stunnel"

  owner = value_for_platform(
    ["ubuntu"] => {"default" => "stunnel4"},
    ["centos", "redhat"] => {"default" => "nobody"}
  )
  group = value_for_platform(
    ["ubuntu"] => {"default" => "stunnel4"},
    ["centos", "redhat"] => {"default" => "nobody"}
  )

  # Saving certificate if provided by user and restricting access
  template "/etc/stunnel/stunnel.pem" do
    source "stunnel.pem.erb"
    cookbook "logging_rsyslog"
    owner owner
    group group
    mode "0400"
    variables(
      :logging_certificate => node[:logging][:certificate]
    )
  end

  # Writing stunnel configuration file
  template "/etc/stunnel/stunnel.conf" do
    source "stunnel.conf.erb"
    cookbook "logging_rsyslog"
    owner "root"
    group "root"
    mode "0644"
    variables(
      :client => params[:client],
      :chroot => value_for_platform(
        ["ubuntu"] => {"default" => "/var/lib/stunnel4/"},
        ["centos", "redhat"] => {"default" => "/var/run/stunnel/"}
      ),
      :owner => owner,
      :group => group,
      :pid => value_for_platform(
        ["ubuntu"] => {"default" => "/stunnel4.pid"},
        ["centos", "redhat"] => {"default" => "/stunnel.pid"}
      ),
      :accept => params[:accept],
      :connect => params[:connect],
      :platform_version => node[:platform_version]
    )
  end

  # Adding init script for CentOS and Redhat
  template "/etc/init.d/stunnel" do
    source "stunnel.sh.erb"
    cookbook "logging_rsyslog"
    owner "root"
    group "root"
    mode "0755"
    backup false
    variables(
      :daemon => value_for_platform(
        ["centos", "redhat"] => {
          "5.8" => "\"/usr/sbin/stunnel\"",
          "default" => "\"/usr/bin/stunnel\""
        }
      )
    )
    not_if { node[:platform] == "ubuntu" }
  end

  execute "Enabling stunnel for CentOS and Redhat" do
    command "/sbin/chkconfig --add stunnel"
    not_if { node[:platform] == "ubuntu" }
  end

  execute "Enabling stunnel for Ubuntu" do
    command "ruby -pi -e \"gsub(/ENABLED=0/,'ENABLED=1')\" /etc/default/stunnel4"
    only_if { node[:platform] == "ubuntu" }
  end

  # Enabling stunnel to start on system boot and restarting to apply new settings
  service value_for_platform(
    ["ubuntu"] => {"default" => "stunnel4"},
    ["centos", "redhat"] => {"default" => "stunnel"}
  ) do
    supports :reload => true, :restart => true, :start => true, :stop => true
    action [:enable, :restart]
  end

end
