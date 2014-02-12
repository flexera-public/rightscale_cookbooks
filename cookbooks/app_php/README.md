# RightScale App PHP Cookbook 

## DESCRIPTION:

* This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).
* Cookbook provides Apache + PHP implementation of the app LWRP.
* Installs and configures an Apache + PHP application server.

## REQUIREMENTS:

* Requires ["app" Lightweight resource cookbook][app] or your own implementation
  of the "app" resource. See "app" cookbook README for details.
* Requires a VM launched from a RightScale managed RightImage

[app]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/app

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `rightscale`
* `web_apache`
* `repo`
* `db_mysql`
* `db_postgres`
* `app`
* `db`

## KNOWN LIMITATIONS:

* Currently apache uses a static configuration and makes no tuning changes for
  resources available on larger instances. However, configuration can be
  overwritten using cookbook override techniques. See [Override Chef Cookbooks](
  http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/08-Chef_Development/Override_Chef_Cookbooks)

## SETUP/USAGE:

* Place `app_php::setup_server_5_3` recipe into your runlist to set up
  the application server specific attributes. This sets up the app provider and
  version.
* Place `app::install_server` recipe after setup_server recipe to install
  the application server.

For more info see: [Release Notes][Notes] (Section ‘PHP App Server’ under
ServerTemplates)

[Notes]: http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/current

Please checkout the tutorial: [PHP App Server][Tutorial]

[Tutorial]: http://support.rightscale.com/ServerTemplates/Infinity/ST/PHP_App_Server_(v13_Infinity)/PHP_App_Server_(v13_Infinity)_-_Tutorial

## DETAILS:

### General

The `app_php` cookbook will help you to install and set up an
Apache + Zend Engine PHP application server, which can connect to a
MySQL or Postgres database server.
Set db/provider_type input in RightScale ServerTemplate to choose database
provider. Place `db::default` recipe before application server installation
to install the database client.

__Apache__

Server version: Apache/2.2.3

Server built: Jun 6 2012 10:00:42

__PHP__

PHP 5.3.6 (cli) (built: Apr 25 2011 10:45:29)

Copyright (c) 1997-2011 The PHP Group

Zend Engine v2.3.0, Copyright (c) 1998-2011 Zend Technologies

Note: The 'php/modules_list' contains an array of package names of PHP modules
to install. We are using packages from the IUS repository, so the package names
must be prepended with php53u. The input type should be set to Array only.

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs can be found in the metadata.rb cookbook file. For
generic app attributes, refer to the app cookbook readme.

###### General attributes

* `node[:app_php][:modules_list]` - List of additional php modules.

### Templates:

* `db.php.erb` - Configuration for project database connection config file used
  in the `app::setup_db_connection` recipe and defined in the
  `:setup_db_connection` action of the `app_php` LWRP.
* `app_server.erb` - Configuration for apache basic application server vhost
  file.

### LWRPs:

`app_php` Lightweight provider is defined in providers/default.rb file and
contains source code for the following actions:

* `:install`
* `:setup_vhost`
* `:start`
* `:stop`
* `:reload`
* `:restart`
* `:code_update`
* `:setup_db_connection`

For more info about these actions please see the `app` cookbook's README.

For normal operations it requires the "app" resource which will act as the
interface to all `app_php` provider logic.

##### Actions

* `:install` - Install packages required for application server setup.
* `:setup_vhost` - Set up apache vhost file with mod_php support included.
* `:start` - Start sequence for PHP application server.
* `:stop` - Stop sequence for PHP application server.
* `:reload` - Reload sequence for PHP application server.
* `:restart` - Restart sequence for PHP application server.
* `:code_update` - Perform project source code update/download using user
  selected "repo" LWRP.
* `:setup_db_connection` - Perform project config/db.php database connection
  configuration.
  The driver type is specified as 'php' and the db_<provider> cookbook's
  `install_client_driver` action performs necessary steps to install the
  database adapter.

##### Usage Example:

For usage examples please see corresponding section in the `app` cookbook's
README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
