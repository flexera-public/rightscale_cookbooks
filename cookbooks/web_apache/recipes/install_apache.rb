#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

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

# Move Apache
content_dir = '/mnt/www'
bash 'move_apache' do
  flags "-ex"
  not_if do File.directory?(content_dir) end
  code <<-EOH
    mkdir -p #{content_dir}
    cp -rf /var/www/. #{content_dir}
    rm -rf /var/www
    ln -nsf #{content_dir} /var/www
  EOH
end

# Move Apache logs
apache_name = node[:apache][:dir].split("/").last
log " Apache name was #{apache_name}"
log " Apache log dir was #{node[:apache][:log_dir]}"

bash 'move_apache_logs' do
  flags "-ex"
  not_if do File.symlink?(node[:apache][:log_dir]) end
  code <<-EOH
    rm -rf #{node[:apache][:log_dir]}
    mkdir -p /mnt/log/#{apache_name}
    ln -s /mnt/log/#{apache_name} #{node[:apache][:log_dir]}
  EOH
end

# Apache Multi-Processing Module configuration
case node[:platform]
  when "centos","redhat","fedora","suse"
    # RedHat based systems has no mpm change scripts included so we have to configure mpm here.
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
  when "debian","ubuntu"
    package "apache2-mpm-#{node[:web_apache][:mpm]}"
end


log "  Started the apache server."

rightscale_marker :end
