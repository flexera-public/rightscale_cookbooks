#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

apache_log_dir = node[:apache][:log_dir]

# Symlink Apache log location.
apache_name = node[:apache][:dir].split("/").last
log "  Apache name was #{apache_name}"
log "  Apache log dir was #{apache_log_dir}"

# Move apache log directory to ephemeral drive
# See cookbooks/rightscale/definitions/rightscale_move_to_ephemeral.rb
# for the "rightscale_move_to_ephemeral" definition.
rightscale_move_to_ephemeral "#{apache_log_dir}" do
  location_on_ephemeral "log/#{apache_name}"
end

# Include the public recipe for basic installation.
# Calls the https://github.com/rightscale/cookbooks/blob/master/apache2/recipes/default.rb recipe.
include_recipe "apache2"

# Persist apache2 resource to node for use in other run lists.
service "apache2" do
  action :nothing
  persist true
end

# Installing ssl support from "apache2" cookbook if enabled.
# Calls the https://github.com/rightscale/cookbooks/blob/master/apache2/recipes/mod_ssl.rb recipe.
if node[:web_apache][:ssl_enable]
  include_recipe "apache2::mod_ssl"
end

# Move default apache content files to ephemeral storage and make symlink.
# See cookbooks/rightscale/definitions/rightscale_move_to_ephemeral.rb
# for the "rightscale_move_to_ephemeral" definition.
rightscale_move_to_ephemeral "/var/www" do
  location_on_ephemeral "www"
  move_content true
end

# Apache Multi-Processing Module configuration.
case node[:platform]
when "centos", "redhat"
  # RedHat based systems have no mpm change scripts included so we have to configure mpm here.
  # Configuring "HTTPD" option to insert it to /etc/sysconfig/httpd file.
  binary_to_use = node[:apache][:binary]
  binary_to_use << ".#{node[:web_apache][:mpm]}" unless node[:web_apache][:mpm] == 'prefork'

  # Updating /etc/sysconfig/httpd to use required worker.
  template "/etc/sysconfig/httpd" do
    source "sysconfig_httpd.erb"
    mode "0644"
    variables(
      :sysconfig_httpd => binary_to_use
    )
    notifies :reload, resources(:service => "apache2"), :immediately
  end
when "ubuntu"
  package "apache2-mpm-#{node[:web_apache][:mpm]}"
end

# Apache Maintenance Mode configuration
template File.join(node[:apache][:dir], 'conf.d', 'maintenance.conf') do
  backup false
  source "maintenance.conf.erb"
  variables(
    :maintenance_file => node[:web_apache][:maintenance_file]
  )
  notifies :restart, resources(:service => "apache2")
end

log "  Started the apache server."

rightscale_marker :end
