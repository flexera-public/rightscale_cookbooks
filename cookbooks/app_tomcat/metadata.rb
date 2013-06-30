maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Cookbook provides Tomcat application server implementation" +
  " of the 'app' Lightweight Resource Provider (LWRP). Installs and configures" +
  " a Tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "app"
depends "repo"
depends "rightscale"
depends "web_apache"

recipe "app_tomcat::setup_server_6",
  "Sets version 6 and node variables specific to the chosen Tomcat version" +
  " to install the tomcat application server."

recipe "app_tomcat::setup_server_7",
  "Sets version 7 and node variables specific to the chosen Tomcat version" +
  " to install the tomcat application server."

# == Default attributes
#
#Code repo attributes
attribute "app_tomcat/code/root_war",
  :display_name => "War file for ROOT",
  :description =>
    "The path to the war file relative to project repo root directory." +
    " Will be renamed to ROOT.war. Example: /dist/app_test.war",
  :required => "recommended",
  :default => "",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

#Java tuning parameters
attribute "app_tomcat/java/xms",
  :display_name => "Tomcat Java XMS",
  :description =>
    "The java Xms argument. Example: 512m",
  :required => "optional",
  :default => "512m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description =>
    "The java Xmx argument. Example: 512m",
  :required => "optional",
  :default => "512m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/permsize",
  :display_name => "Tomcat Java PermSize",
  :description =>
    "The java PermSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/maxpermsize",
  :display_name => "Tomcat Java MaxPermSize",
  :description =>
    "The java MaxPermSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/newsize",
  :display_name => "Tomcat Java NewSize",
  :description =>
    "The java NewSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/maxnewsize",
  :display_name => "Tomcat Java MaxNewSize",
  :description =>
    "The java MaxNewSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/datasource_name",
  :display_name => "Container datasource name",
  :description =>
    "This name is used to set up the database connection with the application" +
    " server. You should set the attribute if your application is compiled to" +
    " use a different datasource name. To set custom datasource you must" +
    " override input value. Example: jdbc/MyConnDB",
  :required => "optional",
  :default => "jdbc/ConnDB",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/internal_port",
  :display_name => "Tomcat Internal Port",
  :description =>
    "Sets the internal port on which Tomcat listens. By default, Tomcat" +
    " listens on localhost port 8080. WARNING: The value for this input" +
    " should NOT be the same as the value in 'app/port' input as it would" +
    " conflict with the Apache listen port and would cause a fatal error when" +
    " the apache service is started.",
  :required => "optional",
  :default => "8080",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]
