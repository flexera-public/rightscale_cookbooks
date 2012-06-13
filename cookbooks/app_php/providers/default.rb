#
# Cookbook Name:: app_php
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop apache
action :stop do
  log "  Running stop sequence"
  service "apache2" do
    action :start
    persist false
  end
end


# Start apache
action :start do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end

# Reload apache
action :reload do
  log "  Running reload sequence"
  service "apache2" do
    action :reload
    persist false
  end
end

# Restart apache
action :restart do
  action_stop
     sleep 5
  action_start
end

# Install Packages and Modules required for PHP application server.
action :install do
  # Installing required packages
  packages = new_resource.packages
 
  if not packages.nil?
    log "  Packages which will be installed #{packages}"

    packages.each do |p|
      package p
    end
  end

  # Installing user-specified additional php modules
  node[:app_php][:modules_list].each do |p|
    package p
  end
  # Installing php modules dependencies
  node[:app_php][:module_dependencies].each do |mod|
    apache_module mod
  end

end


# Setup apache PHP virtual host
action :setup_vhost do

  project_root = new_resource.destination
  php_port = new_resource.port

  # Disable default vhost
  apache_site "000-default" do
    enable false
  end

  # Adds php port to list of ports for webserver to listen on
  app_add_listen_port php_port

  # Configure apache vhost for PHP
  web_app node[:web_apache][:application_name] do
    template "app_server.erb"
    docroot project_root
    vhost_port php_port.to_s
    server_name node[:web_apache][:server_name]
    cookbook "web_apache"
  end

end


# Setup PHP Database Connection
action :setup_db_connection do
  project_root = new_resource.destination
  # Make sure config dir exists
  directory ::File.join(project_root, "config") do
    recursive true
    owner node[:app_php][:app_user]
    group node[:app_php][:app_user]
  end

  db_adapter = node[:app_php][:db_adapter]
  # runs only on db_adapter selection
  if db_adapter == "mysql"
    # Tell MySQL to fill in our connection template
    db_mysql_connect_app ::File.join(project_root, "config", "db.php") do
      template "db.php.erb"
      cookbook "app_php"
      database node[:app_php][:db_schema_name]
      owner node[:app_php][:app_user]
      group node[:app_php][:app_user]
    end
  elsif db_adapter == "postgresql"
    # Tell PostgreSQL to fill in our connection template
    db_postgres_connect_app ::File.join(project_root, "config", "db.php") do
      template "db.php.erb"
      cookbook "app_php"
      database node[:app_php][:db_schema_name]
      owner node[:app_php][:app_user]
      group node[:app_php][:app_user]
    end
  else
    raise "Unrecognized database adapter #{node[:app_php][:db_adapter]}, exiting "
  end
end

# Download/Update application repository
action :code_update do

  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"

  log "  Downloading project repo"

  # Calling "repo" LWRP to download remote project repository
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app_php][:app_user]
    repository node[:repo][:default][:repository]
    persist false
  end

  # Restarting apache
  action_restart

end
