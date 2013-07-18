# RightScale App Tomcat Cookbook

## DESCRIPTION:

* Cookbook provides Tomcat application server implementation of the app LWRP.
* Installs and configures, Tomcat application server.

## REQUIREMENTS:

* Requires ["app" Lightweight resource cookbook][app] or your own implementation
  of the "app" resource. See "app" cookbook README for details.
* Requires a VM launched from a RightScale managed RightImage

[app]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/app

## COOKBOOKS DEPENDENCIES:

Please see the `metadata.rb` file for the latest dependencies.

* `app`
* `db_mysql`
* `db_postgres`
* `repo`
* `rightscale`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place `app_tomcat::setup_server_6` or `app_tomcat::setup_server_7`
  (depending on which application server version to be installed) recipes into
  your runlist to set up the application server specific attributes.
* Place `app::install_server` after setup_server recipe to install the
  application server.
* Set 'jdbc/ConnDB' as your datasource name to set up a database connection with
  the application server.

For more info see: [Release Notes][Notes] (Section ‘Tomcat App Server’ under
ServerTemplates)

[Notes]: http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/current

Please checkout the tutorial: [Tomcat App Server][Tutorial]

[Tutorial]: http://support.rightscale.com/ServerTemplates/Infinity/ST/Tomcat_App_Server_(v13_Infinity)/Tomcat_App_Server_(v13_Infinity)_-_Tutorial

## DETAILS:

### General

The `app_tomcat` cookbook will install and set up the Apache web server with a
mod_jk module and the Tomcat application server, with support for MySQL or
Postgres database servers.
Set db/provider_type input in RightScale ServerTemplate to choose database
provider. Place `db::default` recipe before application server installation
to install the database client.

The Cookbook will create a separate vhost config for the Apache web server,
which will allow Apache to handle static content, such as images and HTML
documents, and forward all requests for dynamic content to Tomcat.

__Apache__

Server version: Apache/2.2.3

Server built: Jun 6 2012 10:00:42

__Apache Tomcat__

__Version 6__

Server.info=Apache Tomcat/6.0.16

Server.number=6.0.16.0

Server.built=Feb 8 2008 10:50:49

Tomcat Native library 1.1.20

mod_jk/1.2.32

__Version 7__

Server.info=Apache Tomcat/7.0.26

Server.number=7.0.26.0

Server.built=Jul 19 2012 03:21:30

Tomcat Native library 1.1.22

mod_jk/1.2.32

__Java__

__Tomcat 6__

Java version "1.6.0_31"

Java(TM) SE Runtime Environment (build 1.6.0_31-b04)

Java HotSpot(TM) 64-Bit Server VM (build 20.6-b01, mixed mode)

__Tomcat 7__

Java version "1.6.0_24"

OpenJDK Runtime Environment (IcedTea6 1.11.4)

OpenJDK 64-Bit Server VM (build 20.0-b12, mixed mode)

also:
* `User defined war file support`
* `Java heap size Xms and Xmx memory limitations tuning`
* `Java NewSize, MaxNewSize, PermSize, MaxPermSize limitations tuning`
* `Application code installation from the remote git, svn or ROS repository`
* `MySQL database db.tomcat connection file configuration`
* `Automatic application vhost file configuration`
* `Automatic logrotate file configuration for Tomcat logs`
* `Collectd monitoring support`

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes that are inputs are in the `metadata.rb` cookbook file.

###### General attributes

* `node[:app_tomcat][:code][:root_war]` -
  Path to the directory which will contain the application for Tomcat.

###### Java heap tuning attributes

* `node[:app_tomcat][:java][:permsize]` -
  The initial value of the permanent generation space size.
* `node[:app_tomcat][:java][:maxpermsize]` -
  The maximum value of the permanent generation space size.
* `node[:app_tomcat][:java][:newsize]` -
  The initial size of new space generation.
* `node[:app_tomcat][:java][:maxnewsize]` -
  The maximum size of new space generation.
* `node[:app_tomcat][:java][:xmx]` -
  The maximum size of the heap used by the JVM.
* `node[:app_tomcat][:java][:xms]` -
  The initial size of the heap used by the JVM.

###### Platform dependent

* `node[:app][:user]` -
  Username. Required for changing the owner of created project dirs.
* `node[:app_tomcat][:alternatives_cmd]` -
  Java alternatives command list.
* `node[:app_tomcat][:jkworkersfile]` -
  Path to file defining workers properties.

### Templates:

#### Defined in `:setup_vhost` LWRP action for the `app::setup_vhost` recipe.

* `apache_mod_jk_vhost.erb` - Configuration for apache vhost file.
* `mod_jk.conf.erb` - Mod_jk configuration template.
* `server_xml.erb` - Tomcat server.xml configuration template.
* `tomcat_conf.erb` - Tomcat.conf configuration template used in the
  `app::setup_vhost` recipe.
* `tomcat_logrotate.conf.erb` - Logrotate for configuration template for
  Tomcat.
* `tomcat_workers.properties.erb` - Tomcat worker configuration template.

#### Defined in `:setup_db_connection` LWRP action for the
`app::setup_db_connection` recipe.

* `web_xml.erb` - Content configuration template for Tomcat.
* `context_xml.erb` - Configuration for project database connection
  config file.
* `catalina.properties.erb` - Tomcat catalina properties with updated
  configuration that loads all java classes from /usr/share/java.

### LWRPs:

`app_tomcat` Lightweight provider is defined in the
`providers/default.rb` file and contains source for the following actions:

* `:install`
* `:setup_vhost`
* `:start`
* `:stop`
* `:reload`
* `:restart`
* `:code_update`
* `:setup_db_connection`
* `:setup_monitoring`

For more info about these actions please see `app` cookbook README.

For normal operations it requires the "app" resource which will act as an 
interface to all `app_tomcat` provider logic.

##### Actions

* `:install` - Install packages required for application server setup.
* `:setup_vhost` - Set up Apache vhost file, with Tomcat module
  directives included. Install and set up Tomcat package dependencies.
* `:start` - Start sequence for Tomcat application server.
* `:stop` - Stop sequence for Tomcat application server.
* `:reload` - Reload sequence for Tomcat application server.
* `:restart` - Restart sequence for Tomcat application server.
* `:code_update` - Perform project source code update/download using user
  selected "repo" LWRP. Set up logrotate config.
* `:setup_db_connection` - Perform project
  `/etc/tomcat{6|7}/context.xml` database file configuration. The driver
  type is specified as 'java' and the db_<provider> cookbook's
  `install_client_driver` action performs necessary steps to install the
  database adapter.
* `:setup_monitoring` - Install and set up of required monitoring software.

##### Usage Example:

For usage examples, please see corresponding section in `app` cookbook README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
