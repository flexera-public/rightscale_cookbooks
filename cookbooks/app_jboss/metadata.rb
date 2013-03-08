maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the jboss application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "app"
depends "repo"
depends "rightscale"

recipe  "app_jboss::setup_server_5_1", "Installs the Jboss application server."

#Code repo attributes
attribute "app_jboss/code/root_war",
  :display_name => "War file for ROOT",
  :description =>
    "The path to the war file relative to project repo root directory." +
    " Will be renamed to ROOT.war. Example: /dist/app_test.war",
  :required => "recommended",
  :default => "",
  :recipes => ["app_jboss::setup_server_5_1"]

#Java tuning parameters
attribute "app_jboss/java/xms",
  :display_name => "JBoss Java XMS",
  :description =>
    "The java Xms argument. Example: 1024m",
  :required => "optional",
  :default => "1024m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/xmx",
  :display_name => "JBoss Java XMX",
  :description =>
    "The java Xmx argument. Example: 1024m",
  :required => "optional",
  :default => "1024m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/permsize",
  :display_name => "JBoss Java PermSize",
  :description =>
    "The java PermSize argument. Example: 256m",
  :required => "optional",
  :default => "256m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/maxpermsize",
  :display_name => "JBoss Java MaxPermSize",
  :description =>
    "The java MaxPermSize argument. Example: 512m",
  :required => "optional",
  :default => "512m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/newsize",
  :display_name => "JBoss Java NewSize",
  :description =>
    "The java NewSize argument. Example: 448m",
  :required => "optional",
  :default => "448m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/maxnewsize",
  :display_name => "JBoss Java MaxNewSize",
  :description =>
    "The java MaxNewSize argument. Example: 448m",
  :required => "optional",
  :default => "448m",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/java/survivor_ratio",
  :display_name => "JBoss Java SurvivorRatio",
  :description =>
    "The java SurvivorRatio argument. Example: 6",
  :required => "optional",
  :default => "6",
  :recipes => ["app_jboss::setup_server_5_1"]

attribute "app_jboss/datasource_name",
  :display_name => "Container datasource name",
  :description => 
    "This name is used to set up the database connection with the application" +
    " server. You should set the attribute if your application is compiled to" +
    " use a different datasource name. To set custom datasource you must" +
    " override input value. Example: jdbc/ConnDB",
  :required => "optional",
  :default => "jdbc/ConnDB",
  :recipes => ["app_jboss::setup_server_5_1"]
