#
# Cookbook Name:: app_jboss
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop jboss service
action :stop do
  log "  Running stop sequence"
  service "jboss" do
    action :stop
    persist false
  end
end

# Start jboss service
action :start do
  log "  Running start sequence"
  service "jboss" do
    action :start
    persist false
  end
end

# Restart jboss service
action :restart do
  log "  Running restart sequence"
  service "jboss" do
    action :restart
    persist false
  end
end

# Installing required packages and prepare system for jboss
action :install do
  packages = new_resource.packages
  install_target = node[:app_jboss][:install_target]

  # Creation of Jboss installation directory, group and user
  directory install_target do
    action :create
    recursive true
  end

  group node[:app][:group]

  user node[:app][:user] do
    comment "JBoss User"
    gid node[:app][:group]
    home install_target
    shell "/sbin/nologin"
  end

  # Download the zip file and extract
  touchfile = ::File.expand_path "~/.jboss_installed"
  bash "extract jboss binaries from zip" do
    not_if { ::File.exists?(touchfile) }
    flags "-ex"
    code <<-EOH
      cd /tmp
      wget -q https://s3.amazonaws.com/rightscale_software/application_sources/jboss-5.1.0.GA.zip
      unzip -q jboss-5.1.0.GA.zip

      mv /tmp/jboss-5.1.0.GA/* #{install_target}
      chown -R jboss:jboss #{install_target}

      touch #{touchfile}
    EOH
  end

  # Install additional packages
  log "  Packages which will be installed: #{packages}"
  packages.each do |pkg|
    log "Installing #{pkg}"
    package pkg
  end

  # Prepare configuration required for Jboss
  log "  Creating run.conf"
  template "#{install_target}/bin/run.conf" do
    action :create
    source "run_conf.erb"
    mode "0644"
    owner node[:app][:user]
    group node[:app][:group]
    cookbook "app_jboss"
    variables(
      :app_user => node[:app][:user],
      :java_xms => node[:app_jboss][:java][:xms],
      :java_xmx => node[:app_jboss][:java][:xmx],
      :java_permsize => node[:app_jboss][:java][:permsize],
      :java_maxpermsize => node[:app_jboss][:java][:maxpermsize],
      :java_newsize => node[:app_jboss][:java][:newsize],
      :java_maxnewsize => node[:app_jboss][:java][:maxnewsize],
      :java_survivor_ratio => node[:app_jboss][:java][:survivor_ratio]
    )
  end

  # Installation of init script and Jboss service
  service "jboss" do
    supports :status => true, :start => true, :stop => true, :restart => true
    action :nothing
  end

  template "/etc/init.d/jboss" do
    action :create
    source "jboss_init.erb"
    mode "0755"
    cookbook "app_jboss"
    notifies :enable, resources(:service => "jboss")
    variables(
      :install_dir => install_target,
      :app_user => node[:app][:user]
    )
  end

  # Removing unnecessary services and securing required services installed
  # by default with jboss
  jboss_deploy_dir = "#{install_target}/server/default/deploy"

  service_dirs = [
    "ROOT.war",
    "admin-console.war",
    "http-invoker.sar",
    "jmx-console.war",
    "jbossws.sar",
    "management",
    "uuid-key-generator.sar",
    "messaging"
  ]
  service_dirs.each do |service|
    directory "#{jboss_deploy_dir}/#{service}" do
      recursive true
      action :delete
    end
  end

  service_files = [
    "mail-service.xml",
    "monitoring-service.xml",
    "schedule-manager-service.xml",
    "jms-ds.xml",
    "jms-ra.rar",
    "quartz-ra.rar",
    "mail-ra.rar",
    "scheduler-service.xml"
  ]
  service_files.each do |service|
    file "#{jboss_deploy_dir}/#{service}" do
      action :delete
      backup false
    end
  end

  # Moving jboss logs to ephemeral to free space on root filesystem
  # See cookbooks/rightscale/definitions/rightscale_move_to_ephemeral.rb
  # for the "rightscale_move_to_ephemeral" definition.
  rightscale_move_to_ephemeral "#{install_target}/server/default/log" do
    location_on_ephemeral "jboss"
    user node[:app][:user]
    group node[:app][:group]
  end

end

# Setup apache virtual host and corresponding jboss configs
action :setup_vhost do

  port = new_resource.port
  app_root = new_resource.root
  install_target = node[:app_jboss][:install_target]

  log "  Updating server.xml"
  template "#{install_target}/server/default/deploy/jbossweb.sar/server.xml" do
    owner node[:app][:user]
    group node[:app][:group]
    mode "0644"
    action :create
    source "server.xml.erb"
    variables(
      :doc_root => app_root,
      :app_ip => node[:app][:ip],
      :listen_port => port
    )
    cookbook "app_jboss"
  end

  log "  Setup logrotate for jboss"
  # See cookbooks/rightscale/definition/rightscale_logrotate_app.rb for the
  # "rightscale_logrotate_app" definition.
  rightscale_logrotate_app "jboss" do
    cookbook "rightscale"
    template "logrotate.erb"
    path [
      "#{install_target}/server/default/log/*.log",
      "#{install_target}/server/default/log/*.out"
    ]
    frequency "size 10M"
    rotate 4
  end

  # Starting jboss service
  # Calls the :start action.
  action_restart

  log "  Setup mod_jk vhost"
  # Setup mod_jk vhost start
  etc_apache = "/etc/#{node[:web_apache][:config_subdir]}"

  # Check if mod_jk is installed
  if !::File.exists?("#{etc_apache}/conf.d/mod_jk.conf")
    connectors_source = "tomcat-connectors-1.2.32-src.tar.gz"

    # Installing required packages depending on platform
    case node[:platform]
    when "ubuntu"
      ubuntu_pkgs = [
        "apache2-mpm-prefork",
        "apache2-threaded-dev",
        "libapr1-dev",
        "libapache2-mod-jk"
      ]
      ubuntu_pkgs.each do |pkg|
        package pkg do
          retries 15
          retry_delay 2
        end
      end

      log "  Removing default plugin conf file to avoid conflict"
      service "apache2" do
        action :stop
        persist false
      end

      bash "conf file deletion" do
        flags "-ex"
        code <<-EOH
          rm #{etc_apache}/mods-available/jk.*
          rm #{etc_apache}/mods-enabled/jk.*
        EOH
      end

      service "apache2" do
        action :start
        persist false
      end

    when "centos", "redhat"
      package "apr-devel"
      package "httpd-devel"

      # Preparing to install tomcat connectors for jboss.
      # Using the same plugin, which already present in app_tomcat cookbook.
      cookbook_file "/tmp/#{connectors_source}" do
        source connectors_source
        cookbook "app_tomcat"
      end

      # Unpacking and building
      bash "install tomcat connectors for jboss" do
        flags "-ex"
        code <<-EOH
          cd /tmp
          mkdir -p /tmp/tc-unpack
          tar xzf #{connectors_source} -C /tmp/tc-unpack --strip-components=1

          cd tc-unpack/native
          ./buildconf.sh
          ./configure --with-apxs=/usr/sbin/apxs --quiet
          make -s
          su -c 'make install'
        EOH
      end

    end

    # Configure workers.properties for mod_jk
    template "#{etc_apache}/conf.d/jboss_workers.properties" do
      action :create
      source "jboss_workers.properties.erb"
      variables(
        :jboss_home => install_target,
        :config_subdir => node[:apache][:config_subdir]
      )
      cookbook "app_jboss"
    end

    # Configure mod_jk.conf
    template "#{etc_apache}/conf.d/mod_jk.conf" do
      action :create
      backup false
      source "mod_jk.conf.erb"
      variables(
        :jkworkersfile => "#{etc_apache}/conf.d/jboss_workers.properties",
        :apache_log_dir => node[:apache][:log_dir],
        :platform => node[:platform]
      )
      cookbook "app_jboss"
    end

    log "  Finished configuring mod_jk, creating the application vhost"

    # Enabling required apache modules
    node[:app][:module_dependencies].each do |mod|
      apache_module mod
    end

  else
    log "  mod_jk already installed, skipping the recipe"
  end

  # Removing preinstalled apache ssl.conf on RHEL images as
  # it conflicts with ports.conf of web_apache
  log "  Removing ssl.conf"
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if { ::File.exists?("/etc/httpd/conf.d/ssl.conf") }
  end

  log "  Generating new apache ports.conf"
  # See cookbooks/app/definitions/app_add_listen_port.rb for the
  # "app_add_listen_port" definition.
  app_add_listen_port port

  # Configuring document root for apache
  if node[:app_jboss][:code][:root_war].empty?
    log "  root_war not defined, setting apache docroot to #{app_root}"
    apache_docroot = "#{app_root}"
  else
    log "  root_war defined, setting apache docroot to #{app_root}/ROOT"
    apache_docroot = "#{app_root}/ROOT"
  end

  log "  Configuring apache vhost for jboss"
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb
  # for the "web_app" definition.
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template        "apache_mod_jk_vhost.erb"
    cookbook        "app_jboss"
    docroot         apache_docroot
    vhost_port      port.to_s
    server_name     node[:web_apache][:server_name]
    allow_override  node[:web_apache][:allow_override]
    apache_log_dir  node[:apache][:log_dir]
  end

  # Apache server restart
  service "apache2" do
    action :restart
    persist false
  end

end

# Setup project db connection
action :setup_db_connection do

  db_name = new_resource.database_name
  db_adapter = node[:db][:provider].match(/^db_([a-z]+)/)[1]
  datasource = node[:app_jboss][:datasource_name]
  install_target = node[:app_jboss][:install_target]
  app_libpath = "#{install_target}/server/default/lib"

  log "  Creating #{db_adapter}-ds.xml for DB: #{db_name} using adapter #{db_adapter} and datasource #{datasource}"
  # See cookbooks/db/definitions/db_connect_app.rb for the "db_connect_app"
  # definition.
  db_connect_app "#{install_target}/server/default/deploy/#{db_adapter}-ds.xml" do
    template      "customdb-ds.xml.erb"
    owner         "#{node[:app][:user]}"
    group         "#{node[:app][:group]}"
    mode          "0644"
    database      db_name
    cookbook      "app_jboss"
    driver_type   "java"
    vars(
      :datasource => datasource
    )
  end

  template "#{install_target}/server/default/deployers/jbossweb.deployer/web.xml" do
    action :create
    source "web.xml.erb"
    owner node[:app][:user]
    group node[:app][:group]
    mode "0644"
    cookbook "app_jboss"
    variables(
      :datasource => datasource
    )
  end

  # Setup jboss-service.xml to include /usr/share/java in JBoss classpath
  java_classpath = "/usr/share/java"
  template "#{install_target}/server/default/conf/jboss-service.xml" do
    action :create
    source "jboss-service.xml.erb"
    owner node[:app][:user]
    group node[:app][:group]
    mode "0644"
    cookbook "app_jboss"
    variables(
      :java_classpath => java_classpath
    )
  end
end

# Setup monitoring tools for jboss
action :setup_monitoring do

  install_target = node[:app_jboss][:install_target]

  log "  Setup of collectd monitoring for jboss"

  # Installing and configuring collectd plugin for JVM monitoring.
  # Using the same plugin, which already present in app_tomcat cookbook.
  cookbook_file "/usr/share/java/collectd.jar" do
    source "collectd.jar"
    mode "0644"
    cookbook "app_tomcat"
  end

  # Linking collectd
  link "#{install_target}/lib/collectd.jar" do
    to "/usr/share/java/collectd.jar"
    not_if { !::File.exists?("/usr/share/java/collectd.jar") }
  end

  # Add collectd support to run.conf
  bash "Add collectd to run.conf" do
    flags "-ex"
    code <<-EOH
      cat <<'EOF'>>"#{install_target}/bin/run.conf"
JAVA_OPTS="\$JAVA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=jboss -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang -javaagent:#{install_target}/lib/collectd.jar"
EOF
    EOH
  end

  # Installing and configuring collectd plugin for JBoss monitoring.
  cookbook_file "/tmp/collectd-plugin-java.tar.gz" do
    source "collectd-plugin-java.tar.gz"
    mode "0644"
    cookbook "app_jboss"
  end

  # Extracting the plugin
  bash "Extracting the plugin" do
    flags "-ex"
    code <<-EOH
    tar xzf /tmp/collectd-plugin-java.tar.gz -C /
    EOH
  end

  cookbook_file "#{node[:rightscale][:collectd_plugin_dir]}/GenericJMX.conf" do
    action :create
    source "GenericJMX.conf"
    mode "0644"
    cookbook "app_jboss"
    notifies :restart, resources(:service => "collectd")
  end

end

# Download/Update application repository
action :code_update do

  deploy_dir = new_resource.destination
  install_target = node[:app_jboss][:install_target]
  log "  Starting code update sequence"
  log "  Current jboss docroot is set to #{deploy_dir}"

  log "  Downloading project repo"
  # Calling "repo" LWRP to download remote project repository
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app][:user]
    repository node[:repo][:default][:repository]
    persist false
  end

  log "  Set ROOT war and code ownership"
  # Preparing user defined war file for jboss auto deploy.
  # Moving file to application root and renaming it to ROOT.war.
  # Manually un-packing the ROOT.war to document root for apache.
  bash "set_root_war_and_chown_home" do
    flags "-ex"
    code <<-EOH
      cd #{deploy_dir}

      if [ ! -z "#{node[:app_jboss][:code][:root_war]}" -a -e "#{deploy_dir}/#{node[:app_jboss][:code][:root_war]}" ] ; then
        mv #{deploy_dir}/#{node[:app_jboss][:code][:root_war]} #{deploy_dir}/ROOT.war
        unzip -d #{deploy_dir}/ROOT #{deploy_dir}/ROOT.war
        # Coping root.war to jboss deploy directory
        ln -s #{deploy_dir}/ROOT #{install_target}/server/default/deploy/app_test.war
      fi

      chown -R #{node[:app][:user]}:#{node[:app][:group]} #{deploy_dir}
      sleep 5
    EOH
    only_if { node[:app_jboss][:code][:root_war] != "ROOT.war" }
  end

end
