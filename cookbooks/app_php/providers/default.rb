#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource app

# Stops apache
action :stop do
  log "  Running stop sequence"
  service "apache2" do
    action :stop
    persist false
  end
end

# Starts apache
action :start do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end

# Reloads apache
action :reload do
  log "  Running reload sequence"
  service "apache2" do
    action :reload
    persist false
  end
end

# Restarts apache
action :restart do
  # Calls the :stop action.
  action_stop
  sleep 5
  # Calls the :start action.
  action_start
end

# Installs packages and modules required for PHP application server.
action :install do
  # Installing required packages
  packages = new_resource.packages

  unless packages.nil?
    log "  Packages which will be installed #{packages}"

    packages.each do |p|
      package p
    end
  end

  # Installing user-specified additional php modules
  log "  Modules which will be installed: #{node[:app_php][:modules_list]}"
  node[:app_php][:modules_list].each do |p|
    package p
  end

  log "  Module dependencies which will be installed:" +
    " #{node[:app_php][:module_dependencies]}"
  # Installing php modules dependencies
  node[:app_php][:module_dependencies].each do |mod|
    # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_module.rb
    # for the "apache_module" definition.
    apache_module mod
  end

end


# Sets up apache PHP virtual host
action :setup_vhost do

  project_root = new_resource.root
  php_port = new_resource.port

  # Disable default vhost
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_site.rb for the "apache_site" definition.
  apache_site "000-default" do
    enable false
  end

  # Adds php port to list of ports for webserver to listen on
  # See cookbooks/app/definitions/app_add_listen_port.rb for the "app_add_listen_port" definition.
  app_add_listen_port php_port

  # Configure apache vhost for PHP
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
  web_app node[:web_apache][:application_name] do
    template "app_server.erb"
    docroot project_root
    vhost_port php_port.to_s
    server_name node[:web_apache][:server_name]
    allow_override node[:web_apache][:allow_override]
    apache_log_dir node[:apache][:log_dir]
    cookbook "app_php"
  end

end


# Sets up PHP Database Connection
action :setup_db_connection do
  project_root = new_resource.destination
  db_name = new_resource.database_name
  # Make sure config dir exists
  directory ::File.join(project_root, "config") do
    recursive true
    owner node[:app][:user]
    group node[:app][:group]
  end

  # Tells selected db_adapter to fill in it's specific connection template
  # See cookbooks/db/definitions/db_connect_app.rb for the "db_connect_app" definition.
  db_connect_app ::File.join(project_root, "config", "db.php") do
    template "db.php.erb"
    cookbook "app_php"
    database db_name
    owner node[:app][:user]
    group node[:app][:group]
    driver_type "php"
  end
end

# Downloads/Updates application repository
action :code_update do

  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"
  log "  Downloading project repo"

  # Calling "repo" LWRP to download remote project repository
  # See cookbooks/repo/resources/default.rb for the "repo" resource.
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app][:user]
    repository node[:repo][:default][:repository]
    persist false
  end

end

# Sets up monitoring for PHP application server. Not implemented.
action :setup_monitoring do

  log "  Monitoring resource is not implemented in php framework yet. Use apache monitoring instead."

end
