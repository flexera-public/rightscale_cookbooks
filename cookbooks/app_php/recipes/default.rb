#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for php application server."
node[:app][:provider] = "app_php"

log "  Install PHP"
package "php5" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse", "fedora"] => { 
      "5.6" => "php53u",
      "5.7" => "php53u",
      "5.8" => "php53u",
      "default" => "php" # CentOS 6+ 
    },
    "default" => 'php'
  )
  action :install
end

log "  Install PHP Pear"
package "php-pear" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse", "fedora"] => { 
      "5.6" => "php53u-pear",
      "5.7" => "php53u-pear",
      "5.8" => "php53u-pear",
      "default" => "php-pear" # CentOS 6+ 
    },
    [ "ubuntu", "debian" ] => { :default => "php-pear" },
    "default" => 'php-pear'
  )
  action :install
end

log "  Install PHP apache support"
package "php apache integration" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse", "fedora"] => { 
      "5.6" => "php53u-zts",
      "5.7" => "php53u-zts",
      "5.8" => "php53u-zts",
      "default" => "php-zts" # CentOS 6+ 
    },
    [ "ubuntu", "debian" ] => { :default => "libapache2-mod-php5" },
    "default" => 'php-zts'
  )
  action :install
end

if node[:app_php][:db_adapter] == "mysql"
  log "  Install PHP mysql support"
  package "php mysql integration" do
    package_name value_for_platform(
      [ "centos", "redhat", "suse", "fedora"] => { 
        "5.6" => "php53u-mysql",
        "5.7" => "php53u-mysql",
        "5.8" => "php53u-mysql",
        "default" => "php-mysql" # CentOS 6+ 
      },
      [ "ubuntu", "debian" ] => { :default => "php5-mysql" },
      "default" => 'php-mysql'
    )
    action :install
  end
elsif node[:app_php][:db_adapter] == "postgresql"
  log "  Install PHP postgres support"
  package "php postgres integration" do
    package_name value_for_platform(
      [ "centos", "redhat", "suse", "fedora"] => { 
        "5.6" => "php53u-pgsql",
        "5.7" => "php53u-pgsql",
        "5.8" => "php53u-pgsql",
        "default" => "php5-pgsql" # CentOS 6+ 
      },
      [ "ubuntu", "debian" ] => { :default => "php5-pgsql" },
      "default" => 'php5-pgsql'
    )
    action :install
  end
else
  raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting "
end


# Setting app LWRP attribute
node[:app][:root] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# PHP shares the same doc root with the application destination
node[:app][:destination] = "#{node[:app][:root]}"

directory "#{node[:app][:destination]}" do
  recursive true
end

rightscale_marker :end
