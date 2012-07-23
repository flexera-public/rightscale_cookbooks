#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for php application server."
node[:app][:provider] = "app_php"

# Preparing list of database adapter packages depending on platform and database adapter
case node[:platform]
when "ubuntu"
  if node[:app_php][:db_adapter] == "mysql"
    node[:app][:packages] = [
      "php5",
      "php5-mysql",
      "php-pear",
      "libapache2-mod-php5"
    ]
  elsif node[:app_php][:db_adapter] == "postgresql"
    node[:app][:packages] = [
      "php5",
      "php5-pgsql",
      "php-pear",
      "libapache2-mod-php5"
    ]
  else
    raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting "
  end
when "centos","redhat"
  if node[:app_php][:db_adapter] == "mysql"
    node[:app][:packages] = [
      "php53u",
      "php53u-mysql",
      "php53u-pear",
      "php53u-zts"
    ]
  elsif node[:app_php][:db_adapter] == "postgresql"
    node[:app][:packages] = [
      "php53u",
      "php53u-pgsql",
      "php53u-pear",
      "php53u-zts"
    ]
  else
    raise "Unrecognized database adapter #{node[:app_php][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end


# Setting app LWRP attribute
node[:app][:root] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# PHP shares the same doc root with the application destination
node[:app][:destination] = "#{node[:app][:root]}"

directory "#{node[:app][:destination]}" do
  recursive true
end

rightscale_marker :end
