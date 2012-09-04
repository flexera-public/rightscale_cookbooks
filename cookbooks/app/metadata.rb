maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "sys_firewall"
depends "rightscale"
depends "repo"
depends "app_php"
depends "app_passenger"
depends "app_tomcat"

recipe "app::default", "Adds the appserver:active=true, appserver:listen_ip=<ip> and appserver:listen_port=<port> tags to your server which identifies it as an application server and tells the load balancer what IP address and port to connect to. For example, a 'master' database server will update its firewall port permissions to accept incoming requests from application servers with this tag."

recipe "app::do_loadbalancers_allow", "Allows connections from all load balancers within a given listener pool which are tagged with loadbalancer:lb=<applistener_name>.  This script should be run on an application server before it makes a request to be connected to the load balancers."

recipe "app::do_loadbalancers_deny", "Denies connections from all load balancers which are tagged with loadbalancer:lb=<applistener_name>.  For example, you can run this script on an application server to deny connections from all load balancers within a given listener pool."

recipe "app::request_loadbalancer_allow", "Sends a request to all application servers tagged with loadbalancer:app=<applistener_name> to allow connections from the server's private IP address. This script should be run on a load balancer before any application servers are attached to it."

recipe "app::request_loadbalancer_deny", "Sends a request to all application servers tagged with loadbalancer:app=<applistener_name> to deny connections from the server's private IP address. This script should be run on a load balancer after disconnecting application servers or upon decommissioning."

recipe "app::setup_vhost", "Set up the application vhost on port 8000. This recipe will call the corresponding provider from the app server cookbook, which creates an apache vhost file."

recipe "app::setup_db_connection", "Set up the database connection file. This recipe will call the corresponding provider from app server cookbook, which creates an application database configuration file."

recipe "app::do_update_code", "Updates application source files from the remote repository. This recipe will call the corresponding provider from the app server cookbook, which will download/update application source code."

recipe "app::setup_monitoring", "Install collectd monitoring. This recipe will call the corresponding provider from the app server cookbook, which installs and configures required monitoring software."

recipe "app::do_server_start", "Runs application server start sequence."

recipe "app::do_server_restart", "Runs application server restart sequence."

recipe "app::do_server_stop", "Runs application server stop sequence."

recipe "app::do_server_reload", "Runs application server reload sequence."

recipe "app::handle_loadbalancers_allow", "Remote recipe run on app server from loadbalancer requesting access. DO NOT RUN."

recipe "app::handle_loadbalancers_deny", "Remote recipe run on app server from loadbalancer revoking access. DO NOT RUN."

attribute "app/port",
  :display_name => "Application Listen Port",
  :description => "The port that the application service is listening on. Example: 8000",
  :default => "8000",
  :recipes => [ 'app::default', 'app::handle_loadbalancers_allow', 'app::handle_loadbalancers_deny' ],
  :required => "optional"

attribute "app/database_name",
  :display_name => "Database Schema Name",
  :description => "Enter the name of the database schema to which applications will connect to. The database schema should have been created when the initial database was first set up. This input will be used to set the application server's database configuration file so that applications can connect to the correct schema within the database.  This input is also used for database dump backups in order to determine which schema will be backed up.  Example: mydbschema",
  :required => "required",
  :recipes => ["app::setup_db_connection"]

attribute "app/db_adapter",
  :display_name => "Database adapter for application",
  :description => "Enter the database adapter which will be used to connect to the database. Example: mysql",
  :default => "mysql",
  :choice => [ "mysql", "postgresql" ],
  :recipes => ["app::default"]

