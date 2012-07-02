#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Stop tomcat service
action :stop do
  log "  Running stop sequence"
  service "tomcat6" do
    action :stop
    persist false
  end
end

# Start tomcat service
action :start do
  log "  Running start sequence"
  service "tomcat6" do
    action :start
    persist false
  end
end

# Restart tomcat service
action :restart do
  log "  Running restart sequence"
  action_stop
  sleep 5
  action_start
end

# Reload tomcat service
action :reload do
  log "  Action not implemented"
end

#Installing required packages and prepare system for tomcat
action :install do

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

  # Installing database adapter for tomcat
  db_adapter = node[:app_tomcat][:db_adapter]
  if db_adapter == "mysql"
    # Removing existing links to database connector
    file "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
      action :delete
    end
    # Link mysql-connector plugin to Tomcat6 lib
    link "/usr/share/tomcat6/lib/mysql-connector-java.jar" do
      to "/usr/share/java/mysql-connector-java.jar"
    end
  elsif db_adapter == "postgresql"
    # Copy to /usr/share/java/postgresql-9.1-901.jdbc4.jar
    cookbook_file "/usr/share/java/postgresql-9.1-901.jdbc4.jar" do
      source "postgresql-9.1-901.jdbc4.jar"
      owner "root"
      group "root"
      cookbook 'app_tomcat'
    end
    # Link postgresql-connector plugin to Tomcat6 lib
    link "/usr/share/tomcat6/lib/postgresql-9.1-901.jdbc4.jar" do
      to "/usr/share/java/postgresql-9.1-901.jdbc4.jar"
    end
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting"
  end

  # Linking RightImage JAVA_HOME to what Tomcat6 expects to be...
  link "/usr/lib/jvm/java" do
    to "/usr/java/default"
  end

  # Moving tomcat logs to ephemeral

  # Deleting old tomcat log directory
  directory "/var/log/tomcat6" do
    recursive true
    action :delete
  end

  # Creating new directory for tomcat logs on ephemeral volume
  directory "/mnt/ephemeral/log/tomcat6" do
    owner node[:app_tomcat][:app_user]
    group node[:app_tomcat][:app_user]
    mode "0755"
    action :create
    recursive true
  end

  # Create symlink from /var/log/tomcat6 to ephemeral volume
  link "/var/log/tomcat6" do
    to "/mnt/ephemeral/log/tomcat6"
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

  log "  Creating tomcat6.conf"
  template "/etc/tomcat6/tomcat6.conf" do
    action :create
    source "tomcat6_conf.erb"
    group "root"
    owner "root"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
      :app_user => node[:app_tomcat][:app_user],
      :java_xms => node[:app_tomcat][:java][:xms],
      :java_xmx => node[:app_tomcat][:java][:xmx],
      :java_permsize => node[:app_tomcat][:java][:permsize],
      :java_maxpermsize => node[:app_tomcat][:java][:maxpermsize],
      :java_newsize => node[:app_tomcat][:java][:newsize],
      :java_maxnewsize => node[:app_tomcat][:java][:maxnewsize]
    )
  end

  # Define internal port for tomcat. It must be different than apache ports
  tomcat_port = port + 1
  log "  Creating server.xml"
  template "/etc/tomcat6/server.xml" do
    action :create
    source "server_xml.erb"
    group "root"
    owner "#{node[:app_tomcat][:app_user]}"
    mode "0644"
    cookbook 'app_tomcat'
    variables(
            :doc_root => app_root,
            :app_port => tomcat_port.to_s
          )
  end

  log "  Setup logrotate for tomcat"
  rightscale_logrotate_app "tomcat" do
    cookbook "rightscale"
    template "logrotate.erb"
    path [ "/var/log/tomcat6/*log", "/var/log/tomcat6/*.out" ]
    frequency "size 10M"
    rotate 4
  end

  # Starting tomcat service
  action_start

  log "  Setup mod_jk vhost"
  # Setup mod_jk vhost start
  etc_apache = "/etc/#{node[:apache][:config_subdir]}"

  # Check if mod_jk is installed
  if !::File.exists?("#{etc_apache}/conf.d/mod_jk.conf")

    connectors_source = "tomcat-connectors-1.2.32-src.tar.gz"

    # Installing required packages depending on platform
    case node[:platform]
    when "ubuntu", "debian"
      ubuntu_p = [ "apache2-mpm-prefork", "apache2-threaded-dev", "libapr1-dev", "libapache2-mod-jk" ]
      ubuntu_p.each do |p|
        package p do
          retries 15
          retry_delay 2
        end
      end

    when "centos","fedora","suse","redhat"

      package "apr-devel" do
        options "-y"
      end

      package "httpd-devel" do
        options "-y"
      end

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
    template "/etc/tomcat6/workers.properties" do
      action :create
      source "tomcat_workers.properties.erb"
      variables(
        :tomcat_name => "tomcat6",
        :config_subdir => node[:apache][:config_subdir]
      )
      cookbook 'app_tomcat'
    end

    # Configure mod_jk.conf
    template "#{etc_apache}/conf.d/mod_jk.conf" do
      action :create
      backup false
      source "mod_jk.conf.erb"
      variables(
        :tomcat_name => "tomcat6",
        :apache_log_dir => node[:apache][:log_dir]
      )
      cookbook 'app_tomcat'
    end

    log "  Finished configuring mod_jk, creating the application vhost"

    # Enabling required apache modules
    node[:app_tomcat][:module_dependencies].each do |mod|
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
  web_app "http-#{port}-#{node[:web_apache][:server_name]}.vhost" do
    template        'apache_mod_jk_vhost.erb'
    cookbook        'app_tomcat'
    docroot         apache_docroot
    vhost_port      port.to_s
    server_name     node[:web_apache][:server_name]
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
  db_adapter = node[:app_tomcat][:db_adapter]
  datasource = node[:app_tomcat][:datasource_name]

  log "  Creating context.xml for DB: #{db_name} using adapter #{db_adapter} and datasource #{datasource}"
  if db_adapter == "mysql"
    db_mysql_connect_app "/etc/tomcat6/context.xml" do
      template      "context_xml.erb"
      owner         "#{node[:app_tomcat][:app_user]}"
      group         "root"
      mode          "0644"
      database      db_name
      datasource    datasource
      cookbook      'app_tomcat'
    end
  elsif db_adapter == "postgresql"
    db_postgres_connect_app "/etc/tomcat6/context.xml" do
      template      "context_xml.erb"
      owner         "#{node[:app_tomcat][:app_user]}"
      group         "root"
      mode          "0644"
      database      db_name
      datasource    datasource
      cookbook      'app_tomcat'
    end
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting"
  end

  log "  Creating web.xml"
  template "/etc/tomcat6/web.xml" do
    source "web_xml.erb"
    owner "#{node[:app_tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end

  # Installing JavaServer Pages Standard Tag Library API
  cookbook_file "/usr/share/tomcat6/lib/jstl-api-1.2.jar" do
    source "jstl-api-1.2.jar"
    owner "#{node[:app_tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end

  # Installing JavaServer Pages Standard Tag Library specifications library
  cookbook_file "/usr/share/tomcat6/lib/jstl-impl-1.2.jar" do
    source "jstl-impl-1.2.jar"
    owner "#{node[:app_tomcat][:app_user]}"
    group "root"
    mode "0644"
    cookbook 'app_tomcat'
  end
end

# Setup monitoring tools for tomcat
action :setup_monitoring do

  log "  Setup of collectd monitoring for tomcat"
  rightscale_enable_collectd_plugin 'exec'

  # Installing and configuring collectd for tomcat
  cookbook_file "/usr/share/java/collectd.jar" do
    source "collectd.jar"
    mode "0644"
    cookbook 'app_tomcat'
  end

  # Linking collectd
  link "/usr/share/tomcat6/lib/collectd.jar" do
    to "/usr/share/java/collectd.jar"
    not_if { !::File.exists?("/usr/share/java/collectd.jar") }
  end

  # Add collectd support to tomcat.conf
  bash "Add collectd to tomcat.conf" do
    flags "-ex"
    code <<-EOH
      cat <<'EOF'>>/etc/tomcat6/tomcat6.conf
CATALINA_OPTS="\$CATALINA_OPTS -Djcd.host=#{node[:rightscale][:instance_uuid]} -Djcd.instance=tomcat6 -Djcd.dest=udp://#{node[:rightscale][:servers][:sketchy][:hostname]}:3011 -Djcd.tmpl=javalang,tomcat -javaagent:/usr/share/tomcat6/lib/collectd.jar"
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
  repo "default" do
    destination deploy_dir
    action node[:repo][:default][:perform_action].to_sym
    app_user node[:app_tomcat][:app_user]
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
      chown -R #{node[:app_tomcat][:app_user]}:#{node[:app_tomcat][:app_user]} #{deploy_dir}
      sleep 5
    EOH
    only_if { node[:app_tomcat][:code][:root_war] != "ROOT.war" }
  end
  # Restarting tomcat service.
  # This will automatically deploy ROOT.war if it is available in application root directory
  action_restart

end
