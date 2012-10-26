#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

apache_log_dir = node[:apache][:log_dir]

# Symlink Apache log location
apache_name = node[:apache][:dir].split("/").last
log "  Apache name was #{apache_name}"
log "  Apache log dir was #{apache_log_dir}"

# Create physical directory holding the logs
directory "/mnt/ephemeral/log/#{apache_name}" do
  action :create
  recursive true
end

# If directory exists for any reason, delete it.
# This should error out if there is content in the dir,
# explicitly setting recursive to false to show behavior.
directory apache_log_dir do
  not_if { File.symlink?(apache_log_dir) }
  recursive false
  action :delete
end

# Create symlink from where apache logs to physical directory
link apache_log_dir do
  to "/mnt/ephemeral/log/#{apache_name}"
end

# Include the public recipe for basic installation
include_recipe "apache2"

# Persist apache2 resource to node for use in other run lists
service "apache2" do
  action :nothing
  persist true
end

# Installing ssl support from "apache2" cookbook if enabled
if node[:web_apache][:ssl_enable]
  include_recipe "apache2::mod_ssl"
end

# Move default apache content files to ephemeral storage and make symlink.
default_web_dir = "/var/www"
content_web_dir = "/mnt/ephemeral/www"

# Creates content_web_dir if it does not exists.
# Gone after stop/start.
directory content_web_dir do
  action :create
  recursive true
end

# If default_web_dir is not a link, move it's files to content_web_dir.
# default_web_dir will later become a symlink to content_web_dir.
bash "Moving #{default_web_dir} to #{content_web_dir}" do
  not_if { File.symlink?(default_web_dir) }
  flags "-ex"
  code <<-EOH
    mv #{default_web_dir}/* #{content_web_dir}
    rmdir #{default_web_dir}
  EOH
end

# Create symlink from default_web_dir to content_web_dir.
link default_web_dir do
  to content_web_dir
end

# Apache Multi-Processing Module configuration
case node[:platform]
when "centos","redhat"
  # RedHat based systems have no mpm change scripts included so we have to configure mpm here.
  # Configuring "HTTPD" option to insert it to /etc/sysconfig/httpd file
  binary_to_use = node[:apache][:binary]
  binary_to_use << ".#{node[:web_apache][:mpm]}" unless node[:web_apache][:mpm] == 'prefork'

  # Updating /etc/sysconfig/httpd  to use required worker
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

log "  Started the apache server."

rightscale_marker :end
