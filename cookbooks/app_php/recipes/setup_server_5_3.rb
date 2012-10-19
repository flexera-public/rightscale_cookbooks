#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for php application server."
node[:app][:provider] = "app_php"
node[:app][:version] = "5.3"
log "  Setting php application server version to 5.3."

# Setting generic app attributes
case node[:platform]
when "ubuntu"
  node[:app][:user] = "www-data"
  node[:app][:group] = "www-data"
  node[:app][:packages] = [
    "php5",
    "php-pear",
    "libapache2-mod-php5"
  ]
when "centos", "redhat"
  node[:app][:user] = "apache"
  node[:app][:group] = "apache"
  node[:app][:packages] = [
    "php53u",
    "php53u-pear",
    "php53u-zts"
  ]
end

# Since, we don't have db/provider_type input in LAMP STs
# node[:db][:provider_type] will be nil.
# We need this condition to check if node[:db][:provider_type] is set
# which happens in case of 3-tier setup with Database Managers.
if not node[:db][:provider_type].nil?
# We do not care about version number here.
# need only the type of database adapter
  node[:app][:db_adapter] = node[:db][:provider_type].match(/^db_([a-z]+)/)[1]
else
  node[:app][:db_adapter] = node[:db][:provider].match(/^db_([a-z]+)/)[1]
end

if node[:app][:db_adapter] == "mysql"
  log "  Install PHP mysql support"
  package "php mysql integration" do
    package_name value_for_platform(
      [ "centos", "redhat" ] => {
        "5.6" => "php53u-mysql",
        "5.7" => "php53u-mysql",
        "5.8" => "php53u-mysql",
        "6.2" => "php53u-mysql",
        "6.3" => "php53u-mysql",
        "default" => "php-mysql"
      },
      "ubuntu" => {
        "default" => "php5-mysql"
      },
      "default" => "php-mysql"
    )
    action :install
  end
elsif node[:app][:db_adapter] == "postgres"
  log "  Install PHP postgres support"
  package "php postgres integration" do
    package_name value_for_platform(
      [ "centos", "redhat" ] => {
        "5.6" => "php53u-pgsql",
        "5.7" => "php53u-pgsql",
        "5.8" => "php53u-pgsql",
        "6.2" => "php53u-pgsql",
        "6.3" => "php53u-pgsql",
        "default" => "php-pgsql"
      },
      "ubuntu" => {
        "default" => "php5-pgsql"
      },
      "default" => "php5-pgsql"
    )
    action :install
  end
else
  raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting "
end

rightscale_marker :end
