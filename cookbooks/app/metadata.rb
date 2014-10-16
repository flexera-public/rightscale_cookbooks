maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale application server management cookbook. This" +
                 " cookbook contains recipes that are generally applicable to" +
                 " all applications."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.6.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "sys_firewall"
depends "rightscale"
depends "repo"
depends "app_php"
depends "app_passenger"
depends "app_tomcat"
depends "db"
depends "app_django"
depends "app_jboss"
depends "app_php54"

recipe "app::install_server",
  "Adds the appserver:active=true, appserver:listen_ip=<ip> and" +
  " appserver:listen_port=<port> tags to your server which identifies it" +
  " as an application server and tells the load balancer what IP address" +
  " and port to connect to. For example, a 'master' database server" +
  " will update its firewall port permissions to accept incoming requests" +
  " from application servers with this tag."

recipe "app::do_loadbalancers_allow",
  "Allows connections from all load balancers within a given listener pool" +
  " which are tagged with loadbalancer:<pool_name>=lb." +
  " This script should be run on an application server before it makes" +
  " a request to be connected to the load balancers."

recipe "app::do_loadbalancers_deny",
  "Denies connections from all load balancers which are tagged with" +
  " loadbalancer:<pool_name>=lb. For example, you can run this" +
  " script on an application server to deny connections from all load" +
  " balancers within a given listener pool."

recipe "app::request_loadbalancer_allow",
  "Sends a request to all application servers tagged with" +
  " loadbalancer:<pool_name>=app to allow connections from the server's" +
  " private IP address. This script should be run on a load balancer before" +
  " any application servers are attached to it."

recipe "app::request_loadbalancer_deny",
  "Sends a request to all application servers tagged with" +
  " loadbalancer:<pool_name>=app to deny connections from the server's" +
  " private IP address. This script should be run on a load balancer after" +
  " disconnecting application servers or upon decommissioning."

recipe "app::setup_vhost",
  "Sets up the application vhost on selected port. This recipe will call" +
  " the corresponding provider from the app server cookbook, which creates" +
  " an apache vhost file."

recipe "app::setup_db_connection",
  "Sets up the database connection file. This recipe will call" +
  " the corresponding provider from app server cookbook, which creates" +
  " an application database configuration file."

recipe "app::do_update_code",
  "Updates application source files from the remote repository. This recipe" +
  " will call the corresponding provider from the app server cookbook," +
  " which will download/update application source code."

recipe "app::setup_monitoring",
  "Installs collectd monitoring. This recipe will call the corresponding" +
  " provider from the app server cookbook, which installs and configures" +
  " required monitoring software."

recipe "app::do_server_start",
  "Runs application server start sequence."

recipe "app::do_server_restart",
  "Runs application server restart sequence."

recipe "app::do_server_stop",
  "Runs application server stop sequence."

recipe "app::do_server_reload",
  "Runs application server reload sequence."

recipe "app::handle_loadbalancers_allow",
  "Runs remote recipe on app server from loadbalancer requesting access." +
  " DO NOT RUN."

recipe "app::handle_loadbalancers_deny",
  "Runs remote recipe on app server from loadbalancer revoking access." +
  " DO NOT RUN."

attribute "app/port",
  :display_name => "Application Listen Port",
  :description =>
    "The port that the application service is listening on. Example: 8000",
  :default => "8000",
  :recipes => [
    "app::install_server",
    "app::handle_loadbalancers_allow",
    "app::handle_loadbalancers_deny"
  ],
  :required => "optional"

attribute "app/database_name",
  :display_name => "Database Schema Name",
  :description =>
    "Enter the name of the database schema to which applications will" +
    " connect to.The database schema should have been created when the" +
    " initial database was first set up. This input will be used to set" +
    " the application server's database configuration file so that" +
    " applications can connect to the correct schema within the database." +
    " NOTE: LAMP servers use this input for database dump backups in" +
    " order to determine which schema will be backed up. Example: mydbschema",
  :required => "required",
  :recipes => ["app::setup_db_connection"]

attribute "app/backend_ip_type",
  :display_name => "Application IP Type Given to Load Balancer",
  :description =>
    "Specify the IP type where the application server is listening." +
    " Example: private",
  :choice => ["public", "private"],
  :required => "optional",
  :default => "private",
  :recipes => ["app::install_server"],
  :required => "optional"
