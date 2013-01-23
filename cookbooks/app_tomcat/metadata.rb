maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the tomcat application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.3.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "app"
depends "repo"
depends "rightscale"
depends "web_apache"

recipe "app_tomcat::setup_server_6", "Set version 6 " +
  "and node variables specific to the chosen Tomcat version " +
  "to install the tomcat application server."

recipe "app_tomcat::setup_server_7", "Set version 7 " +
  "and node variables specific to the chosen Tomcat version " +
  "to install the tomcat application server."

# == Default attributes
#
#Code repo attributes
attribute "app_tomcat/code/root_war",
  :display_name => "War file for ROOT",
  :description => "The path to the war file relative to project repo " +
    "root directory. Will be renamed to ROOT.war. Example: /dist/app_test.war",
  :required => "recommended",
  :default => "",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

#Java tuning parameters
attribute "app_tomcat/java/xms",
  :display_name => "Tomcat Java XMS",
  :description => "The java Xms argument. Example: 512m",
  :required => "optional",
  :default => "512m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/xmx",
  :display_name => "Tomcat Java XMX",
  :description => "The java Xmx argument. Example: 512m",
  :required => "optional",
  :default => "512m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/permsize",
  :display_name => "Tomcat Java PermSize",
  :description => "The java PermSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/maxpermsize",
  :display_name => "Tomcat Java MaxPermSize",
  :description => "The java MaxPermSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/newsize",
  :display_name => "Tomcat Java NewSize",
  :description => "The java NewSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/java/maxnewsize",
  :display_name => "Tomcat Java MaxNewSize",
  :description => "The java MaxNewSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]

attribute "app_tomcat/datasource_name",
  :display_name => "Container datasource name",
  :description => "This name is used to set up the database connection " +
    "with the application server. You should set the attribute " +
    "if your application is compiled to use a different datasource name. " +
    "To set custom datasource you must override input value. " +
    "Example: jdbc/MyConnDB",
  :required => "optional",
  :default => "jdbc/ConnDB",
  :recipes => [
    "app_tomcat::setup_server_6",
    "app_tomcat::setup_server_7"
  ]
