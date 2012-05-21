#
# Cookbook Name::app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for rails-passenger."
node[:app][:provider] = "app_passenger"
node[:app][:database_name] = node[:app_passenger][:project][:db][:schema_name]
node[:app][:root] = "#{node[:app][:destination]}/public"

case node[:platform]
  when "ubuntu","debian"
    node[:app][:packages] = ["libopenssl-ruby", "libcurl4-openssl-dev", "apache2-mpm-prefork", "apache2-prefork-dev", "libapr1-dev", "libcurl4-openssl-dev"]
  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    node[:app][:packages] = ["zlib-devel", "openssl-devel", "readline-devel", "curl-devel", "openssl-devel", "httpd-devel", "apr-devel", "apr-util-devel", "readline-devel"]
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end


log " Preparing tomcat document root variable"
if node[:repo][:default][:destination].empty?
  log "  Your repo/default/destination input is no set. Setting project root to default: /srv/tomcat6/webapps/ "
  node[:app_passenger][:project_home]= "/home/rails/"
else
  node[:app_passenger][:project_home]= node[:repo][:default][:destination]
end

# Creating new project root directory
directory "#{node[:app_passenger][:project_home]}" do
  recursive true
end
# Cooking doc root variable
node[:app_passenger][:deploy_dir] = "#{node[:app_passenger][:project_home]}/#{node[:web_apache][:application_name]}"

# Setting app LWRP attribute
node[:app][:destination]="#{node[:app_passenger][:deploy_dir]}"

rightscale_marker :end
