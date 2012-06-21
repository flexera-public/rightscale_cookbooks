maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/configures the apache2 webserver"
version          "12.1.0"

supports "centos", "~> 5.8"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

recipe "web_apache::default", "Runs web_apache::install_apache."
recipe "web_apache::do_start", "Runs service apache start."
recipe "web_apache::do_stop", "Runs service apache stop."
recipe "web_apache::do_restart", "Runs service apache restart."
recipe "web_apache::do_enable_default_site", "Enables the default vhost."
recipe "web_apache::install_apache", "Installs and configures the Apache2 webserver."
recipe "web_apache::setup_frontend", "Frontend apache vhost. Select ssl_enabled for SSL."
recipe "web_apache::setup_frontend_ssl_vhost", "Frontend apache vhost with SSL enabled."
recipe "web_apache::setup_frontend_http_vhost", "Frontend apache vhost with SSL enabled."
recipe "web_apache::setup_monitoring", "Installs the collectd-apache plugin for monitoring support."


all_recipes = [
  "web_apache::default",
  "web_apache::install_apache",
  "web_apache::setup_frontend_ssl_vhost",
  "web_apache::setup_frontend_http_vhost",
  "web_apache::setup_frontend",
]
other_recipes = [
  "web_apache::do_start",
  "web_apache::do_stop",
  "web_apache::do_restart"
]

depends "apache2"
depends "rightscale"

attribute "web_apache",
  :display_name => "apache hash",
  :description => "Apache Web Server",
  :type => "hash"

attribute "web_apache/mpm",
  :display_name => "Multi-Processing Module",
  :description => "Defines the multi-processing module setting in httpd.conf.  Use 'worker' for Rails/Tomcat/Standalone frontends and 'prefork' for PHP. Example: prefork",
  :required => "optional",
  :recipes => all_recipes,
  :choice => [ "prefork", "worker" ],
  :default =>  "prefork"

attribute "web_apache/ssl_enable",
  :display_name => "SSL Enable",
  :description => "Enables SSL ('https'). Example: true",
  :recipes => [
    "web_apache::install_apache",
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend"
   ],
  :required => "optional",
  :choice => [ "true", "false" ],
  :default =>  "false"

attribute "web_apache/ssl_certificate",
  :display_name => "SSL Certificate",
  :description => "The name of your SSL Certificate. Example: cred:SSL_CERT",
  :required => "optional",
  :default =>  "",
  :recipes => [
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend" 
  ]

attribute "web_apache/ssl_certificate_chain",
  :display_name => "SSL Certificate Chain",
  :description => "Your SSL Certificate Chain. Example: cred:SSL_CERT_CHAIN",
  :required => "optional",
  :default =>  "",
  :recipes => [
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend" 
  ]

attribute "web_apache/ssl_key",
  :display_name => "SSL Certificate Key",
  :description => "Your SSL Certificate Key. Example: cred:SSL_KEY",
  :required => "optional",
  :default =>  "",
  :recipes => [
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend" 
  ]

attribute "web_apache/ssl_passphrase",
  :display_name => "SSL Passphrase",
  :description => "Your SSL passphrase. Example: cred:SSL_PASSPHRASE",
  :required => "optional",
  :default =>  "",
  :recipes => [
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend" 
  ]

attribute "web_apache/application_name",
  :display_name => "Application Name",
  :description => "Sets the directory for your application's web files (/home/webapps/Application Name/current/).  If you have multiple applications, you can run the code checkout script multiple times, each with a different value for the 'Application Name' input, so each application will be stored in a unique directory.  This must be a valid directory name.  Do not use symbols in the name. Example: myapp",
  :required => "optional",
  :default => "myapp",
  :recipes => [
    "web_apache::setup_frontend_ssl_vhost",
    "web_apache::setup_frontend_http_vhost",
    "web_apache::setup_frontend",
    "web_apache::default"
  ]
