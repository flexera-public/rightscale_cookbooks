#
# Cookbook Name:: logging_rsyslog
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :configure_stunnel, :accept => "514", :connect => "515", :client => nil do

  # Installing stunnel
  package "stunnel"

  certificate = ::File.join(node[:logging][:cert_dir], "stunnel.pem")

  # Saving certificate if provided by user
  template certificate do
    source "stunnel.pem.erb"
    not_if { node[:logging][:certificate].nil? }
  end

  # Generating a self-signed certificate for stunnel if user didn't supply one
  execute "Generating a self-signed certificate for stunnel" do
    command "openssl req -new -x509 -days 3650 -nodes -out #{certificate} -keyout #{certificate} -subj \"/C=US/ST=CA/L=SB/O=Rightscale/OU=Rightscale/CN=Rightscale/emailAddress=support@rightscale.com\""
    only_if { node[:logging][:certificate].nil? }
  end

  # Restricting access to the certificate
  file certificate do
    owner "nobody"
    group "nobody"
    mode "0400"
    action :touch
  end

  # Writing stunnel configuration file
  template "/etc/stunnel/stunnel.conf" do
    action :create
    source "stunnel.conf.erb"
    owner "root"
    group "root"
    mode "0644"
    cookbook "logging_rsyslog"
    variables(
      :certificate => certificate,
      :client => params[:client],
      :accept => params[:accept],
      :connect => params[:connect]
    )
  end

  # Enabling stunnel for ubuntu
  execute "Enabling stunnel" do
    command "ruby -pi -e \"gsub(/ENABLED=0/,'ENABLED=1')\" /etc/default/stunnel4"
    only_if { node[:platform] == "ubuntu" }
  end

  # Adding init script for centOS and Redhat
  cookbook_file "/etc/init.d/stunnel" do
    source "stunnel.sh"
    cookbook "logging_rsyslog"
    owner "root"
    group "root"
    mode "0755"
    backup false
    not_if { node[:platform] == "ubuntu" }
  end

  # Enabling stunnel to start on system boot and restarting to apply new settings
  service [:logging][:stunnel_service] do
    supports :reload => true, :restart => true, :start => true, :stop => true
    action [:enable, :restart]
  end

end
