#
# Cookbook Name:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# By default passenger will use "conservative" spawn method for more info see: http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerSpawnMethod
set_unless[:app_passenger][:rails_spawn_method]="conservative"
# Path to html maintenance page, which will be displayed, when main application is unavailable
set_unless[:app_passenger][:apache][:maintenance_page]=""
# By default apache will serve any existing local files directly (except actionable ones)
set_unless[:app_passenger][:apache][:serve_local_files]="true"
# List of required apache modules
set[:app_passenger][:module_dependencies] = ["proxy", "proxy_ajp"]

# Defining apache user, group and log directory path depending on platform.
case node[:platform]
  when "ubuntu"
    set[:app_passenger][:apache][:user]="www-data"
    set[:app_passenger][:apache][:group]="www-data"
    set[:app_passenger][:apache][:log_dir]="/var/log/apache2"
  when "centos","redhat","redhatenterpriseserver"
    set[:app_passenger][:apache][:user]="apache"
    set[:app_passenger][:apache][:group]="apache"
    set[:app_passenger][:apache][:log_dir]="/var/log/httpd"
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Path to Ruby EE gem directory
set[:app_passenger][:ruby_gem_base_dir]="/opt/ruby-enterprise/lib/ruby/gems/1.8"
# Path to Ruby EE gem executable
set[:app_passenger][:gem_bin]="/opt/ruby-enterprise/bin/gem"
# Path to Ruby EE ruby executable
set[:app_passenger][:ruby_bin]="/opt/ruby-enterprise/bin/ruby"
# Path to passenger module for apache
set[:app_passenger][:apache_psr_install_module]="/opt/ruby-enterprise/bin/passenger-install-apache2-module"
# By default rails application environment variable is set to "development"
set_unless[:app_passenger][:project][:environment]="development"
# List of additional gems, required for rails application
set_unless[:app_passenger][:project][:gem_list]=""
# List of rake commands required for rails application initialization
set_unless[:app_passenger][:project][:custom_cmd]=""
# Application database name
set_unless[:app_passenger][:project][:db][:schema_name]=""
# Type of database adapter which rails application will use
set_unless[:app_passenger][:project][:db][:adapter]="mysql"
