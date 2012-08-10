#
# Cookbook Name:: app_django
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

action :install do
  # Installing required packages
  packages = new_resource.packages
  dversion = node[:app_django][:version].to_i
  log "  Packages which will be installed: #{packages}"

  packages.each do |p|
    package p
  end

  # Installing python modules dependencies
  log "  Module dependencies which will be installed: #{node[:app][:module_dependencies]}"
  node[:app][:module_dependencies].each do |mod|
    apache_module mod
  end

 # Install pip if not found
  bash "install-pip" do
    code <<-EOF
      easy_install pip
    EOF
    not_if "which pip"
  end

  # install Django 1.4
  python_pip "django" do
    version "#{dversion}"
    action :install
  end

  # Installing database adapter for Django
  db_adapter = node[:app][:db_adapter]
  log "Installing python packages for database support"
  if db_adapter == "mysql"
    python_pip "MySQL-python" do
      version "1.2.3"
      action :install
    end
  elsif db_adapter == "postgresql"
    python_pip "psycopg2" do
      version "2.4.5"
      action :install
    end
  else
    raise "Unrecognized database adapter #{node[:app][:db_adapter]}, exiting"
  end
end

# Setup apache PHP virtual host
action :setup_vhost do

  project_root = new_resource.destination
  django_port = new_resource.port

  # Disable default vhost
  log "  Unlinking default apache vhost"
  apache_site "000-default" do
    enable false
  end

  # Adds django port to list of ports for webserver to listen on
  app_add_listen_port django_port

  # Configure apache vhost for Django
  log "  Creating apache.vhost"
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template                   "apache_mod_wsgi_vhost.erb"
    docroot                    project_root
    vhost_port                 django_port.to_s
    server_name                node[:web_apache][:server_name]
    debug                      node[:app_django][:debug_mode]
    apache_log_dir             node[:app_django][:apache][:log_dir]
    apache_maintenance_page    node[:app_django][:apache][:maintenance_page]
    apache_serve_local_files   node[:app_django][:apache][:serve_local_files]
    cookbook                   "app_django"
  end

  # Define internal port for tomcat. It must be different than apache ports
  log "  Creating wsgi.py"
  template "#{project_root}/wsgi.py" do
    action :create
    source "wsgi.py.erb"
    group "root"
    owner "#{node[:app][:user]}"
    cookbook 'app_django'
    variables(
            :doc_root => project_root,
            :project =>  node[:web_apache][:application_name]
          )
  end

end

# Setup Django Database Connection
action :setup_db_connection do

  project_root = new_resource.destination
  db_name = new_resource.database_name
  db_adapter = node[:app][:db_adapter]
  debug_mode = node[:app_django][:debug_mode]

  # moves django default settings file to settings_default and create settings.py from django template
  settingsfile = ::File.expand_path(::File.join(project_root, "settings.py"))
  defaultfile = ::File.expand_path(::File.join(project_root, "settings_default.py"))
  ruby_block "move django settings" do
    only_if { ::File.exists?(settingsfile) }
    not_if { ::File.exists?(defaultfile) }
    block do
      require 'fileutils'
      FileUtils.mv(settingsfile, defaultfile)
    end
  end

  # Tells selected db_adapter to fill in it's specific connection template
  log "  Creating settings.py for DB: #{db_name} using adapter #{db_adapter}"
  db_connect_app ::File.join(project_root, "settings.py") do
    template      "settings.py.erb"
    owner         node[:app][:user]
    group         node[:app][:group]
    database      db_name
    debug         debug_mode
    cookbook      "app_django"
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
    app_user node[:app][:user]
    repository node[:repo][:default][:repository]
    persist false
  end

  # Restarting apache
  action_restart

end
