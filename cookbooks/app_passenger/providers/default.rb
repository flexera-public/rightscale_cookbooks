#
# Cookbook Name:: app_passenger
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop apache/passenger
action :stop do
  log "  Running stop sequence"
  service "apache2" do
    action :stop
    persist false
  end
end

# Start apache/passenger
action :start do
  log "  Running start sequence"
  service "apache2" do
    action :start
    persist false
  end
end

# Reload apache/passenger
action :reload do
  log "  Running reload sequence"
  service "apache2" do
    action :reload
    persist false
  end
end

# Restart apache/passenger
action :restart do
  log "  Running restart sequence"
  action_stop
  sleep 5
  action_start
end

# Installing required packages to system
action :install do

  # Installing some apache development headers required for rubyEE
  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages.each do |p|
    package p
  end

  log "  Installing Ruby Enterprise Edition..."
  # Moving rubyEE sources to /tmp folder preparing to install
  cookbook_file "/tmp/ruby-enterprise-installed.tar.gz" do
    source "ruby-enterprise_x86_64.tar.gz"
    mode "0644"
    only_if do node[:kernel][:machine].include? "x86_64" end
    cookbook 'app_passenger'
  end

  bash "install_ruby_EE" do
    flags "-ex"
    code <<-EOH
      tar xzf /tmp/ruby-enterprise-installed.tar.gz -C /opt/
    EOH
    only_if do ::File.exists?("/tmp/ruby-enterprise-installed.tar.gz")  end
  end


  # Installing passenger module
  log "  Installing passenger"
  bash "Install apache passenger gem" do
    flags "-ex"
    code <<-EOH
      /opt/ruby-enterprise/bin/gem install passenger -q --no-rdoc --no-ri
    EOH
    not_if do (::File.exists?("/opt/ruby-enterprise/bin/passenger-install-apache2-module")) end
  end


  bash "Install apache passenger module" do
    flags "-ex"
    code <<-EOH
      /opt/ruby-enterprise/bin/passenger-install-apache2-module --auto
    EOH
    not_if "test -e #{node[:app_passenger][:ruby_gem_base_dir].chomp}/gems/passenger*/ext/apache2/mod_passenger.so"
  end

end

# Setup apache/passenger virtual host
action :setup_vhost do
  port = new_resource.port

  # Removing preinstalled apache ssl.conf as it conflicts with ports.conf of web:apache
  log "  Removing ssl.conf"
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if do ::File.exists?("/etc/httpd/conf.d/ssl.conf")  end
  end

  # Enabling required apache modules
  node[:app_passenger][:module_dependencies].each do |mod|
    apache_module mod
  end

  # Apache fix on RHEL
  file "/etc/httpd/conf.d/README" do
    action :delete
    only_if do node[:platform] == "redhat" end
  end


  log "  Generating new apache ports.conf"
  node[:apache][:listen_ports] = port.to_s

  # Generation of new apache ports.conf
  template "#{node[:apache][:dir]}/ports.conf" do
    cookbook "apache2"
    source "ports.conf.erb"
    variables :apache_listen_ports => node[:apache][:listen_ports]
  end

  log "  Unlinking default apache vhost"
  apache_site "000-default" do
    enable false
  end

  # Generation of new vhost config, based on user prefs
  log "  Generating new apache vhost"
  project_root = new_resource.root
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template                   "basic_vhost.erb"
    cookbook                   'app_passenger'
    docroot                    project_root
    vhost_port                 port.to_s
    server_name                node[:web_apache][:server_name]
    rails_env                  node[:app_passenger][:project][:environment]
    apache_install_dir         node[:app_passenger][:apache][:install_dir]
    apache_log_dir             node[:app_passenger][:apache][:log_dir]
    ruby_bin                   node[:app_passenger][:ruby_bin]
    ruby_base_dir              node[:app_passenger][:ruby_gem_base_dir]
    rails_spawn_method         node[:app_passenger][:rails_spawn_method]
    destination                node[:app][:destination]
    apache_maintenance_page    node[:app_passenger][:apache][:maintenance_page]
    apache_serve_local_files   node[:app_passenger][:apache][:serve_local_files]
    passenger_user             node[:app_passenger][:apache][:user]
    passenger_group            node[:app_passenger][:apache][:group]
  end


end


# Setup project db connection
action :setup_db_connection do

  deploy_dir = new_resource.destination
  db_name = new_resource.database_name
  db_adapter = node[:app_passenger][:project][:db][:adapter]

  log "  Generating database.yml"
  # Tell MySQL to fill in our connection template
  if db_adapter == "mysql"
    db_mysql_connect_app "#{deploy_dir.chomp}/config/database.yml" do
      template      "database.yml.erb"
      cookbook      "app_passenger"
      owner         node[:app_passenger][:apache][:user]
      group         node[:app_passenger][:apache][:group]
      database      db_name
    end
  # Tell PostgreSQL to fill in our connection template
  elsif db_adapter == "postgresql"
    db_postgres_connect_app "#{deploy_dir.chomp}/config/database.yml" do
      template      "database.yml.erb"
      cookbook      "app_passenger"
      owner         node[:app_passenger][:apache][:user]
      group         node[:app_passenger][:apache][:group]
      database      db_name
    end
  else
    raise "Unrecognized database adapter #{node[:app_passenger][:project][:db][:adapter]}, exiting "
  end

  # Defining $RAILS_ENV
  ENV['RAILS_ENV'] = node[:app_passenger][:project][:environment]

  # Creating bash file for manual $RAILS_ENV setup
  log "  Creating bash file for manual $RAILS_ENV setup"
  template "/etc/profile.d/rails_env.sh" do
    mode         '0744'
    source       "rails_env.erb"
    cookbook     'app_passenger'
    variables(
        :environment => node[:app_passenger][:project][:environment]
      )
  end

end

# Download/Update application repository
action :code_update do
  deploy_dir = new_resource.destination

  log "  Starting code update sequence"
  log "  Current project doc root is set to #{deploy_dir}"

  log "  Starting source code download sequence..."
  # Calling "repo" LWRP to download remote project repository
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app_passenger][:apache][:user]
    environment "RAILS_ENV" => "#{node[:app_passenger][:project][:environment]}"
    repository node[:repo][:default][:repository]
    persist false
  end

  # Moving rails application log directory to ephemeral

  # Removing log directory, preparing to symlink
  directory "#{deploy_dir}/log" do
    action :delete
    recursive true
  end

  # Creating new rails application log  directory on ephemeral volume
  directory "/mnt/ephemeral/log/rails/#{node[:web_apache][:application_name]}" do
    owner node[:app_passenger][:apache][:user]
    mode "0755"
    action :create
    recursive true
  end

  # Symlinking application log directory to ephemeral volume
  link "#{deploy_dir}/log" do
    to "/mnt/ephemeral/log/rails/#{node[:web_apache][:application_name]}"
  end

  log "  Generating new logrotate config for rails application"
  rightscale_logrotate_app "rails" do
    cookbook "rightscale"
    template "logrotate.erb"
    path ["#{deploy_dir}/log/*.log" ]
    frequency "size 10M"
    rotate 4
    create "660 #{node[:app_passenger][:apache][:user]} #{node[:app_passenger][:apache][:group]}"
  end

end
