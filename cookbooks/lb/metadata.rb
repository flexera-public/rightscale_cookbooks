maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RighScale LB Manager"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

supports "centos", "~> 5.8"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

depends "lb_haproxy"
depends "lb_clb"
depends "lb_elb"
depends "apache2"
depends "app", ">= 1.0"

recipe "lb::default", "This loads the required load balancer resources."
recipe "lb::setup_load_balancer", "Installs the load balancer and adds the loadbalancer:<pool_name>=lb tags to your server, which identifies it as a load balancer for a given listener pool. This tag is used by application servers to request connection/disconnection."
recipe "lb::handle_attach", "Remote recipe executed by do_attach_request. DO NOT RUN."
recipe "lb::handle_detach", "Remote recipe executed by do_detach_request. DO NOT RUN."
recipe "lb::do_attach_all", "Registers all running application servers with the loadbalancer:<pool_name>=app tags. This should be run on a load balancer to connect all application servers in a deployment."
recipe "lb::do_attach_request", "Sends request to all servers with loadbalancer:<pool_name>=lb tag to attach the current server to the listener pool. This should be run by a new application server that is ready to accept connections."
recipe "lb::do_detach_request", "Sends request to all servers with loadbalancer:<pool_name>=lb tag to detach the current server from the listener pool. This should be run by an application server at decommission."
recipe "lb::setup_reverse_proxy_config", "Configures Apache reverse proxy."
recipe "lb::setup_monitoring", "Installs the load balancer collectd plugin for monitoring support."
recipe "lb::setup_advanced_configuration", "recipe for advanced load balancer configuration"

#Comma separated list of URIs or FQDNs to create HAProxy pools for.
attribute "lb/pools",
  :display_name => "Load balancer Pools",
  :description => "Comma-separated list of URIs or FQDNs for which the load balancer will create server pools to answer website requests.
First entry will be the default backend and will answer for all URIs and FQDNs not listed here.
A single entry of any name, e.g. 'default', 'www.mysite.com' or '/appserver', will mimic basic behavior of one load balancer with one pool of application servers.
This will be used for naming server pool backends.
Application servers can provide any numbers of URIs or FQDNs to join corresponding server pool backends.
Example: www.mysite.com, api.mysite.com, /serverid, default",
  :required => "recommended",
  :default => "default",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::handle_attach",
    "lb::do_detach_request",
    "lb::handle_detach",
    "lb::setup_load_balancer",
    "lb::do_attach_all"
  ]

attribute "lb/stats_uri",
  :display_name => "Status URI",
  :description => "The URI for the load balancer statistics report page. This page lists the current session, queued session, response error, health check error, server status, etc. for each load balancer group. Example: /haproxy-status",
  :required => "optional",
  :default => "/haproxy-status",
  :recipes => [
    "lb::setup_load_balancer"
  ]

attribute "lb/stats_user",
  :display_name => "Status Page Username",
  :description => "The username that is required to access the load balancer statistics report page.  Example: cred:STATS_USER",
  :required => "optional",
  :default => "",
  :recipes => [
    "lb::setup_load_balancer"
  ]

attribute "lb/stats_password",
  :display_name => "Status Page Password",
  :description => "The password that is required to access the load balancer statistics report page.  Example: cred:STATS_PASSWORD",
  :required => "optional",
  :default => "",
  :recipes => [
    "lb::setup_load_balancer"
  ]

attribute "lb/session_stickiness",
  :display_name => "Use Session Stickiness",
  :description => "Determines session stickiness. Set to 'True' to use session stickiness, where the load balancer will reconnect a session to the last server it was connected to (via a cookie). Set to 'False' if you do not want to use sticky sessions; the load balancer will establish a connection with the next available server. Example: true",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true",
  :recipes => [
    "lb::handle_attach"
  ]

attribute "lb/health_check_uri",
  :display_name => "Health Check URI",
  :description => "The URI that the load balancer will use to check the health of a server. It is only used for HTTP (not HTTPS) requests. Example: /",
  :required => "optional",
  :default => "/",
  :recipes => [
    "lb::setup_load_balancer",
    "lb::handle_attach"
  ]

attribute "lb/service/provider",
  :display_name => "Load Balance Provider",
  :description => "Specify the load balance provider to use: either 'lb_haproxy' for HAProxy, 'lb_elb' for AWS Load Balancing, or 'lb_clb' for Rackspace Cloud Load Balancing. Example: lb_haproxy",
  :required => "recommended",
  :default => "lb_haproxy",
  :choice => ["lb_haproxy", "lb_clb", "lb_elb"],
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/region",
  :display_name => "Load Balance Service Region",
  :description => "If you are using Rackspace's Cloud Load Balancing service, specify the cloud region or data center being used for this service. Example: ORD (Chicago)",
  :required => "optional",
  :default => "ORD (Chicago)",
  :choice => ["ORD (Chicago)", "DFW (Dallas/Ft. Worth)", "LON (London)"],
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/lb_name",
  :display_name => "Load Balance Service Name",
  :description => "Name of the Cloud Load Balancer or Elastic Load Balancer device. Example: mylb",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/account_id",
  :display_name => "Load Balance Service ID",
  :description => "If you are using Rackspace's Cloud Load Balancing service, specify the Rackspace username to use for authentication. Example: cred:RACKSPACE_USERNAME",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/service/account_secret",
  :display_name => "Load Balance Service Secret",
  :description => "If you are using Rackspace's Cloud Load Balancing service, specify the Rackspace API key to use for authentication. Example: cred:RACKSPACE_AUTH_KEY",
  :required => "optional",
  :recipes => [
    "lb::default",
    "lb::do_attach_request",
    "lb::do_detach_request"
  ]

attribute "lb/advanced_config/backend_authorized_users",
  :display_name => "Backend authorized users",
  :description => "List of usernames/passwords which will be used to setup authorization process to selected pools. The format is: pool_name1{username1:password1, username2:password2,..., usernameN:passwordN}; ... pool_nameN{username1:password1, username2:password2,..., usernameN:passwordN}  Note http-request auth feature, supported only from haproxy v 1.4. Example: /serverid{admin:adminpass1, admin2:adminpass2}; /appserver{user1:usernpass1}",
  :required => "optional",
  :recipes => [
    "lb::setup_advanced_config"
  ]
