#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for php application server."

node[:app][:provider] = "app_php"

case node[:platform]
when "ubuntu", "debian"
  if node[:app_php][:db_adapter] == "mysql"
    node[:app][:packages] = ["php5", "php5-mysql", "php-pear", "libapache2-mod-php5"]
  elsif node[:app_php][:db_adapter] == "postgresql"
    node[:app][:packages] = ["php5", "php5-pgsql", "php-pear", "libapache2-mod-php5"]
  else
    raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting "
  end
when "centos","fedora","suse","redhat"
  if node[:app_php][:db_adapter] == "mysql"
    node[:app][:packages] = ["php53u", "php53u-mysql", "php53u-pear", "php53u-zts"]
  elsif node[:app_php][:db_adapter] == "postgresql"
    node[:app][:packages] = ["php53u", "php53u-pgsql", "php53u-pear", "php53u-zts"]
  else
    raise "Unrecognized database adapter #{node[:app_php][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end


log " Preparing php document root variable"
if node[:repo][:default][:destination].empty?
  log "Your repo/default/destination input is no set. Setting project root to default: /home/php/webapps/ "
  node[:app_php][:project_home]= "/home/php/webapps/"
else
  node[:app_php][:project_home]= node[:repo][:default][:destination]
end

#Creating new project root directory
directory "#{node[:app_php][:project_home]}" do
  recursive true
end
#Cooking doc root variable
node[:app_php][:doc_root] = "#{node[:app_php][:project_home]}/#{node[:web_apache][:application_name]}"

# setting app LWRP attribute
node[:app][:destination]="#{node[:app_php][:doc_root]}"


rightscale_marker :end
