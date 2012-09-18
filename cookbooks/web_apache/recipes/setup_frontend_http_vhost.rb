#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# This recipe will setup Apache vhost on port 80

http_port = "80"

# Disable default vhost
apache_site "000-default" do
  enable false
end

# Updating apache listen ports configuration
template "#{node[:apache][:dir]}/ports.conf" do
  cookbook "apache2"
  source "ports.conf.erb"
  variables :apache_listen_ports => http_port
end

# Configure apache vhost
web_app "#{node[:web_apache][:application_name]}.frontend" do
  template "apache.conf.erb"
  docroot node[:web_apache][:docroot]
  vhost_port http_port
  server_name node[:web_apache][:server_name]
  allow_override node[:web_apache][:allow_override]
  notifies :restart, resources(:service => "apache2")
end

rightscale_marker :end
