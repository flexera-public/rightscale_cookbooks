#
# Cookbook Name:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# List of required apache modules
set[:app][:module_dependencies] = ["proxy", "proxy_ajp"]

# By default apache will serve any existing local files directly (except actionable ones)
default[:app_passenger][:apache][:serve_local_files] = "true"
# By default passenger will use "conservative" spawn method for more info see: http://www.modrails.com/documentation/Users%20guide%20Apache.html#PassengerSpawnMethod
default[:app_passenger][:rails_spawn_method] = "conservative"
# Path to Ruby gem executable
set[:app_passenger][:gem_bin] = "/usr/bin/gem"
# Path to Ruby ruby executable
set[:app_passenger][:ruby_bin] = "/usr/bin/ruby"
# By default rails application environment variable is set to "development"
default[:app_passenger][:project][:environment] = "development"
# List of additional gems, required for rails application
default[:app_passenger][:project][:gem_list] = ""
# List of rake commands required for rails application initialization
default[:app_passenger][:project][:custom_cmd] = ""
