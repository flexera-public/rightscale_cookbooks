#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop tomcat service
action :stop do

  version = node[:app][:version].to_i
  log "  Running stop sequence"
  service "tomcat#{version}" do
    action :stop
    persist false
  end
end

# Start tomcat service
action :start do

  version = node[:app][:version].to_i
  log "  Running start sequence"
  service "tomcat#{version}" do
    action :start
    persist false
  end
end

# Restart tomcat service
action :restart do
  log "  Running restart sequence"
  # Calls the :stop action.
  action_stop
  sleep 5
  # Calls the :start action.
  action_start
end

# Reload tomcat service
action :reload do
  log "  Action not implemented"
end

#Installing required packages and prepare system for tomcat
action :install do

  version = node[:app][:version].to_i

  packages = new_resource.packages
  log "  Packages which will be installed: #{packages}"
  packages.each do |p|
    log "installing #{p}"
    package p

    # eclipse-ecj and symlink must be installed FIRST
    if p=="eclipse-ecj" || p=="ecj-gcj"
      file "/usr/share/java/ecj.jar" do
        action :delete
      end

      link "/usr/share/java/ecj.jar" do
        to "/usr/share/java/eclipse-ecj.jar"
      end
    end

  end
  # Executing java alternatives command to set installed java as default.
  execute "alternatives" do
    command "#{node[:app_tomcat][:alternatives_cmd]}"
    action :run
  end

  # Linking RightImage JAVA_HOME to what Tomcat6 expects to be...
  link "/usr/lib/jvm/java" do
    to "/usr/java/default"
  end

  # Moving tomcat logs to ephemeral

  # Deleting old tomcat log directory
  directory "/var/log/tomcat#{version}" do
    recursive true
    action :delete
  end

  # Creating new directory for tomcat logs on ephemeral volume
  directory "/mnt/ephemeral/log/tomcat#{version}" do
    owner node[:app][:user]
    group node[:app][:group]
    mode "0755"
    action :create
    recursive true
  end

  # Create symlink from /var/log/tomcat#{version} to ephemeral volume
  link "/var/log/tomcat#{version}" do
    to "/mnt/ephemeral/log/tomcat#{version}"
  end

  # Symlinking to new jvm-exports
  bash "Create /usr/lib/jvm-exports/java if possible" do
    flags "-ex"
    code <<-EOH
      if [ -d "/usr/lib/jvm-exports" ] && [ ! -d "/usr/lib/jvm-exports/java" ]; then
        cd /usr/lib/jvm-exports
        java_dir=`ls -d java-* -1 2>/dev/null | tail -1`

        if ! test "$java_dir" = "" ; then
          ln -s $java_dir java
        fi
      fi
    EOH
  end

end

# Setup apache virtual host and corresponding tomcat configs
action :setup_vhost do

  port = new_resource.port
  app_root = new_resource.root
  version = node[:app][:version].to_i

  log "  Creating tomcat#{version} configuration file"
  template "#{node[:app_tomcat][:configuration_file_path]}" do
    action :create
    source "tomcat_conf.erb"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :app_user => node[:app][:user],
      :version => version,
      :java_xms => node[:app_tomcat][:java][:xms],
      :java_xmx => node[:app_tomcat][:java][:xmx],
      :java_permsize => node[:app_tomcat][:java][:permsize],
      :java_maxpermsize => node[:app_tomcat][:java][:maxpermsize],
      :java_newsize => node[:app_tomcat][:java][:newsize],
      :java_maxnewsize => node[:app_tomcat][:java][:maxnewsize],
      :platform => node[:platform],
      :platform_ver => node[:platform_version].to_i
    )
  end

  # Define internal port for tomcat. It must be different than apache ports
  tomcat_port = port + 1
  log "  Creating server.xml"
  template "/etc/tomcat#{version}/server.xml" do
    action :create
    source "server_xml.erb"
    group "root"
    owner "#{node[:app][:user]}"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :doc_root => app_root,
      :app_port => tomcat_port.to_s
    )
  end

  log "  Setup logrotate for tomcat"
  # See cookbooks/rightscale/definition/rightscale_logrotate_app.rb for the "rightscale_logrotate_app" definition.
  rightscale_logrotate_app "tomcat" do
    cookbook "rightscale"
    template "logrotate.erb"
    path ["/var/log/tomcat#{version}/*log", "/var/log/tomcat#{version}/*.out"]
    frequency "size 10M"
    rotate 4
  end

  # Starting tomcat service
  # Calls the :start action.
  action_start

  log "  Setup mod_jk vhost"
  # Setup mod_jk vhost start
  etc_apache = "/etc/#{node[:web_apache][:config_subdir]}"

  # Check if mod_jk is installed
  if !::File.exists?("#{etc_apache}/conf.d/mod_jk.conf")

    connectors_source = "tomcat-connectors-1.2.32-src.tar.gz"

    # Installing required packages depending on platform
    case node[:platform]
    when "ubuntu"
      ubuntu_p = ["apache2-mpm-prefork", "apache2-threaded-dev", "libapr1-dev", "libapache2-mod-jk"]
      ubuntu_p.each do |p|
        package p do
          retries 15
          retry_delay 2
        end
      end

    when "centos", "redhat"

      package "apr-devel"

      package "httpd-devel"

      # Preparing to install tomcat connectors
      cookbook_file "/tmp/#{connectors_source}" do
        source "#{connectors_source}"
        cookbook 'app_tomcat'
      end

      # Unpacking and building
      bash "install tomcat connectors" do
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
    template node[:app_tomcat][:jkworkersfile] do
      action :create
      source "tomcat_workers.properties.erb"
      variables(
        :version => version,
        :config_subdir => node[:web_apache][:config_subdir]
      )
      cookbook 'app_tomcat'
    end

    # Configure mod_jk.conf
    template "#{etc_apache}/conf.d/mod_jk.conf" do
      action :create
      backup false
      source "mod_jk.conf.erb"
      variables(
        :jkworkersfile => node[:app_tomcat][:jkworkersfile],
        :apache_log_dir => node[:apache][:log_dir]
      )
      cookbook 'app_tomcat'
    end

    log "  Finished configuring mod_jk, creating the application vhost"

    # Enabling required apache modules
    node[:app][:module_dependencies].each do |mod|
      # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/apache_module.rb for the "apache_module" definition.
      apache_module mod
    end

  else
    log "  mod_jk already installed, skipping the recipe"
  end

  # Removing preinstalled apache ssl.conf on RHEL images as it conflicts with ports.conf of web_apache
  log "  Removing ssl.conf"
  file "/etc/httpd/conf.d/ssl.conf" do
    action :delete
    backup false
    only_if { ::File.exists?("/etc/httpd/conf.d/ssl.conf") }
  end

  log "  Generating new apache ports.conf"
  # See cookbooks/app/definitions/app_add_listen_port.rb for the "app_add_listen_port" definition.
  app_add_listen_port port

  # Configuring document root for apache
  if node[:app_tomcat][:code][:root_war].empty?
    log "  root_war not defined, setting apache docroot to #{app_root}"
    apache_docroot = "#{app_root}"
  else
    log "  root_war defined, setting apache docroot to #{app_root}/ROOT"
    apache_docroot = "#{app_root}/ROOT"
  end

  log "  Configuring apache vhost for tomcat"
  # See https://github.com/rightscale/cookbooks/blob/master/apache2/definitions/web_app.rb for the "web_app" definition.
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template 'apache_mod_jk_vhost.erb'
    cookbook 'app_tomcat'
    docroot apache_docroot
    vhost_port port.to_s
    server_name node[:web_apache][:server_name]
    allow_override node[:web_apache][:allow_override]
    apache_log_dir node[:apache][:log_dir]
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
  datasource = node[:app_tomcat][:datasource_name]
  version = node[:app][:version].to_i

  log "  Creating context.xml for DB: #{db_name} using datasource #{datasource}"
  # See cookbooks/db/definitions/db_connect_app.rb for the "db_connect_app" definition.
  db_connect_app "/etc/tomcat#{version}/context.xml" do
    template "context_xml.erb"
    owner "#{node[:app][:user]}"
    group "root"
    mode "0644"
    database db_name
    cookbook "app_tomcat"
    driver_type "java"
    vars(
      :datasource => datasource
    )
  end

  log "  Creating web.xml"
  template "/etc/tomcat#{version}/web.xml" do
    source "web_xml.erb"
    owner "#{node[:app][:user]}"
    group "root"
    mode "0644"
    variables(
      :datasource => datasource
    )
    cookbook 'app_tomcat'
  end

  # Creating catalina.properties file with /usr/share/java included in the common loader
  # so tomcat will pick up all jar files available in that directory
  log "  Creating catalina.properties"
  template "/etc/tomcat#{version}/catalina.properties" do
    source "catalina.properties.erb"
    owner "#{node[:app][:user]}"
    group "root"
    mode "0644"
    cookbook "app_tomcat"
  end

  # Installing JavaServer Pages Standard Tag Library API
  cookbook_file "/usr/share/tomcat#{version}/lib/jstl-api-1.2.jar" do
    source "jstl-api-1.2.jar"
    owner "#{node[:app][:user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end

  # Installing JavaServer Pages Standard Tag Library specifications library
  cookbook_file "/usr/share/tomcat#{version}/lib/jstl-impl-1.2.jar" do
    source "jstl-impl-1.2.jar"
    owner "#{node[:app][:user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end
end

# Setup monitoring tools for tomcat
action :setup_monitoring do

  version=node[:app][:version].to_i
  log "  Setup of collectd monitoring for tomcat"
  # See cookbooks/rightscale/definitions/rightscale_enable_collectd_plugin.rb for the "rightscale_enable_collectd_plugin" definition.
  rightscale_enable_collectd_plugin 'exec'

  # Installing and configuring collectd for tomcat
  cookbook_file "/usr/share/java/collectd.jar" do
    source "collectd.jar"
    mode "0644"
    cookbook 'app_tomcat'
  end

  # Linking collectd
  link "/usr/share/tomcat#{version}/lib/collectd.jar" do
    to "/usr/share/java/collectd.jar"
    not_if { !::File.exists?("/usr/share/java/collectd.jar") }
  end

  # Add collectd support to tomcat.conf
  bash "Add collectd to tomcat configuration file" do
    flags "-ex"
    code <<-EOH
      cat <<'EOF'>>"#{node[:app_tomcat][:configuration_file_path]}"
CATALINA_OPTS="\$CATALINA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=tomcat#{version} -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang,tomcat -javaagent:/usr/share/tomcat#{version}/lib/collectd.jar"
    EOH
  end


end

# Download/Update application repository
action :code_update do

  deploy_dir = new_resource.destination
  log "  Starting code update sequence"
  log "  Current tomcat docroot is set to #{deploy_dir}"

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

  log "  Set ROOT war and code ownership"
  # Preparing user defined war file for tomcat auto deploy.
  # Moving file to application root and renaming it to ROOT.war.
  bash "set_root_war_and_chown_home" do
    flags "-ex"
    code <<-EOH
      cd #{deploy_dir}
      if [ ! -z "#{node[:app_tomcat][:code][:root_war]}" -a -e "#{deploy_dir}/#{node[:app_tomcat][:code][:root_war]}" ] ; then
        mv #{deploy_dir}/#{node[:app_tomcat][:code][:root_war]} #{deploy_dir}/ROOT.war
      fi
      chown -R #{node[:app][:user]}:#{node[:app][:group]} #{deploy_dir}
      sleep 5
    EOH
    only_if { node[:app_tomcat][:code][:root_war] != "ROOT.war" }
  end
  # Restarting tomcat service.
  # This will automatically deploy ROOT.war if it is available in application root directory
  # Calls the :restart action.
  action_restart

end
