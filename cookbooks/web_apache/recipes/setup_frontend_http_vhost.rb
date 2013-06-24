#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# This recipe will setup Apache vhost on port 80

http_port = "80"

# Disable default vhost.
# See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_site.rb for the "apache_site" definition.
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
# See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
web_app "#{node[:web_apache][:application_name]}.frontend" do
  template "apache.conf.erb"
  docroot node[:web_apache][:docroot]
  vhost_port http_port
  server_name node[:web_apache][:server_name]
  allow_override node[:web_apache][:allow_override]
  apache_log_dir node[:apache][:log_dir]
  notifies :restart, resources(:service => "apache2")
end
