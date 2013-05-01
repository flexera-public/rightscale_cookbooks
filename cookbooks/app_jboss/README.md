# RightScale App JBoss Cookbook

## DESCRIPTION:

* Cookbook provides JBoss application server implementation of the app LWRP.
* Installs and configures the JBoss application server.

## REQUIREMENTS:

* Requires ["app" Lightweight resource cookbook][app] or your own implementation
  of the "app" resource. See "app" cookbook README for details.
* Requires a VM launched from a RightScale managed RightImage
* Tested on the following RightImages:
  * CentOS 6.2
  * Ubuntu 12.04

[app]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/app

## COOKBOOKS DEPENDENCIES:

Please see the `metadata.rb` file for the latest dependencies.

* `app`
* `repo`
* `rightscale`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place `app_jboss::setup_server` recipe into your runlist to set up the
  application server specific attributes.
* Place `app::install_server` after setup_server recipe to install the
  application server.
* Set 'jdbc/ConnDB' as your datasource name to set up a database connection with
  the application server.

For more info see: [Release Notes][Notes] (Section ‘JBoss App Server’ under
ServerTemplates)

[Notes]: http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/current

Please check out the tutorial: [JBoss App Server][Tutorial]

[Tutorial]: http://support.rightscale.com/03-Tutorials/JBoss_App_Server

## DETAILS:

### General

The `app_jboss` cookbook will install and set up the Apache web server
with a mod_jk module and the JBoss application server, with support for MySQL or
Postgres database servers. The Cookbook will create a separate vhost config for
the Apache web server, which will allow Apache to handle static content, such as
images and HTML documents, and forward all requests for dynamic content to
JBoss.

Features currently supported are
* User defined war file support
* Java heap size Xms and Xmx memory limitations tuning
* Java NewSize, MaxNewSize, PermSize, MaxPermSize limitations tuning
* Application code installation from the remote git, svn or ROS repository
* MySQL/Postgesql database JBoss connection file configuration
* Automatic application vhost file configuration
* Automatic logrotate file configuration for JBoss logs
* Collectd monitoring support

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes that are inputs are in the `metadata.rb` cookbook file.

###### General attributes

* `node[:app_jboss][:code][:root_war]` -
  Path to the directory which will contain the application for JBoss.

###### Java heap tuning attributes

"Permanent Generation" space holds Class and Object instances, and their related
metadata. "Young Generation" space is the location where new objects are
created. It consists of two survivor spaces called `to space` and
`from space`.

* `node[:app_jboss][:java][:permsize]` -
  The initial size of "permanent generation" space.
* `node[:app_jboss][:java][:maxpermsize]` -
  The maximum size of "permanent generation" space.
* `node[:app_jboss][:java][:newsize]` -
  The initial size of "young generation" space.
* `node[:app_jboss][:java][:maxnewsize]` -
  The maximum size of "young generation" space.
* `node[:app_jboss][:java][:xmx]` -
  The maximum size of the heap used by the JVM.
* `node[:app_jboss][:java][:xms]` -
  The initial size of the heap used by the JVM.

For more information about the Java tuning parameters check out [Java Heap
Tuning Parameters][Doc]

[Doc]: http://docs.oracle.com/cd/E19528-01/819-4742/abeik/index.html

###### Platform dependent

* `node[:app][:user]` -
  Username for changing the owner of created project dirs.
* `node[:app_jboss][:alternatives_cmd]` -
  Alternative command for selecting Java.

### Templates:

#### Defined in `:install` LWRP action for the `app::default` recipe.

* `run_conf.erb` - JBoss configuration template used by JBoss start-up
  script.
* `jboss_init.erb` - Start-up init script for JBoss.

#### Defined in `:setup_vhost` LWRP action for the `app::setup_vhost` recipe.

* `server_xml.erb` - JBoss server.xml configuration template.
* `apache_mod_jk_vhost.erb` - Configuration for apache vhost file.
* `mod_jk.conf.erb` - Mod_jk configuration template.
* `jboss_workers.properties.erb` - JBoss worker configuration template.

#### Defined in `:setup_db_connection` LWRP action for the
`app::setup_db_connection` recipe.

* `customdb-ds.xml.erb` - Configuration for project database connection
  configuration file.
* `web.xml.erb` - JBoss Content configuration template.

### LWRPs:

`app_jboss` Lightweight provider is defined in the `providers/default.rb` file
and contains source for the following actions:

* `:install` -
  Install packages required for application server setup.
* `:setup_vhost` -
  Set up Apache vhost file with mod_jk. Install and set up JBoss package
  dependencies. Set up logrotate for JBoss.
* `:start` -
  Start sequence for JBoss application server.
* `:stop` -
  Stop sequence for JBoss application server.
* `:reload` -
  Reload sequence for JBoss application server.
* `:restart` -
  Restart sequence for JBoss application server.
* `:code_update` -
  Perform project source code update/download using user selected "repo" LWRP.
* `:setup_db_connection` -
  Configure `(mysql/postgres)-ds.xml` JBoss db specific configuration
  file with database connection information.
* `:setup_monitoring` -
  Install and set up of required monitoring software.

For more info about these actions please see `app` cookbook README.

For normal operations it requires the "app" resource which will act as an
interface to all `app_jboss` provider logic.

##### Usage Example:

For usage examples, please see corresponding section in
`app` cookbook README.

##### Unwanted applications and services

JBoss comes with a lot of services and your enterprise applications may not need
all of them. After installation, the following applications and services are
removed to boost application server performance.

*  Home page server - (deploy/ROOT.war)
*  JMX Console server - (deploy/jmx-console.war)
*  Web Console server - (deploy/management)
*  Unique ID key generator - (deploy/uuid-key-generator.sar)
*  HTTP Invoker service - (deploy/http-invoker.sar)
*  Quartz scheduler service - (deploy/quartz-ra.rar)
*  Mail service - (deploy/mail-service.xml, deploy/mail-ra.rar)
*  Monitoring service - (deploy/monitoring-service.xml)
*  Scheduler service - (deploy/scheduler-service.xml,
   deploy/schedule-manager-service.xml)
*  Messaging (JMS) service - (deploy/messaging, deploy/jms-ds.xml,
   deploy/jms-ra.rar)
*  Admin console - (deploy/admin-console.war)
*  JBoss Web Services - (deploy/jbossws.sar)

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
