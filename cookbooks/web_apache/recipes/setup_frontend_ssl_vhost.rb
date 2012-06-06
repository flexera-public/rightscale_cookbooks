#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing only for RHEL based systems
package "mod_ssl" do
  not_if { node[:platform].include? "ubuntu" }
end

# Setup Apache vhost on following ports
https_port = "443"
http_port  = "80"

# Disable default vhost
apache_site "000-default" do
  enable false
end

ssl_dir =  "/etc/#{node[:apache][:config_subdir]}/rightscale.d/key"

# Creating directory where certificate files will be stored
directory ssl_dir do
  mode "0700"
  recursive true
end

ssl_certificate_file = ::File.join(ssl_dir, "#{node[:web_apache][:server_name]}.crt")
ssl_key_file = ::File.join(ssl_dir, "#{node[:web_apache][:server_name]}.key")

# Updating crt file config
template ssl_certificate_file do
  mode "0400"
  source "ssl_certificate.erb"
end

# Updating key file config
template ssl_key_file do
  mode "0400"
  source "ssl_key.erb"
end

log "  Using passphrase to decrypt certificate"
bash "decrypt openssl keyfile" do
  flags "-ex"
  environment({ :OPT_SSL_PASSPHRASE => node[:web_apache][:ssl_passphrase] })
  code "openssl rsa -passin env:OPT_SSL_PASSPHRASE -in #{ssl_key_file} -passout env:OPT_SSL_PASSPHRASE -out #{ssl_key_file}"
  only_if { node[:web_apache][:ssl_passphrase]!=nil }
end


# Optional certificate chain
if node[:web_apache][:ssl_certificate_chain]
  log "  Using SSL certificate chain"
  ssl_certificate_chain_file = ::File.join(ssl_dir, "#{node[:web_apache][:server_name]}.sf_crt")
  template "#{ssl_certificate_chain_file}" do
    mode "0400"
    source "ssl_certificate_chain.erb"
  end
else
  ssl_certificate_chain_file = nil
end

node[:apache][:listen_ports].push(http_port) unless node[:apache][:listen_ports].include?(http_port)
node[:apache][:listen_ports].push(https_port) unless node[:apache][:listen_ports].include?(https_port)

# Updating apache listen ports configuration
template "#{node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => node[:apache][:listen_ports]
  notifies :restart, resources(:service => "apache2")
end

# Configure apache ssl vhost
web_app "#{node[:web_apache][:application_name]}.frontend.https" do
  template "apache_ssl_vhost.erb"
  docroot node[:web_apache][:docroot]
  vhost_port https_port
  server_name node[:web_apache][:server_name]
  ssl_certificate_chain_file ssl_certificate_chain_file
  ssl_passphrase node[:web_apache][:ssl_passphrase]
  ssl_certificate_file ssl_certificate_file
  ssl_key_file ssl_key_file
  notifies :restart, resources(:service => "apache2")
end

# Configure apache non-ssl vhost
web_app "#{node[:web_apache][:application_name]}.frontend.http" do
  template "apache.conf.erb"
  docroot node[:web_apache][:docroot]
  vhost_port http_port
  server_name node[:web_apache][:server_name]
  notifies :restart, resources(:service => "apache2"), :immediately
end

rightscale_marker :end
