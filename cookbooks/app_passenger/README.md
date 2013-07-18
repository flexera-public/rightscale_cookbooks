# RightScale App Passenger Cookbook

## DESCRIPTION:

* Cookbook provides Apache + Passenger implementation of the 'app' LWRP.
* Installs and configures, Apache + Passenger application servers.

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
* `app`
* `db`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place `app_passenger::setup_server_3_0` recipe into your runlist
  to set up the application server specific attributes. This sets up the app
  provider and version.
* Place `app::install_server` recipe after setup_server recipe to install
  the application server.

## DETAILS:

### General:

The `app_passenger` cookbook will install and set up Apache +
Phusion Passenger application server configured to connect with a MySQL or
Postgres database server. Set db/provider_type input in RightScale
ServerTemplate to choose database provider. Place `db::default` recipe
before application server installation to install the database client.

__Apache__

Server version: Apache/2.2.3

Server built: Jun 6 2012 10:00:42

__Phusion Passenger__

Phusion Passenger version 3.0.19

also:
* `Rails spawn method input`
* `Custom rails command input`
* `Bundler support`
* `Input for user defined gems installation`
* `Application code installation from remote git, svn or Remote Object Store
  (ROS) location`
* `MySQL or Postgres database connection file configuration`
* `Automatic application vhost file configuration`

For more info see: [Release Notes][Notes] (Section 'Apache-Rails-Passenger App
Server' under ServerTemplates)

[Notes]: http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/current

Please checkout the tutorial: [Apache-Rails-Passenger App Server][Tutorial]

[Tutorial]: http://support.rightscale.com/ServerTemplates/Infinity/ST/Apache-Rails-Passenger_App_Server_(v13_Infinity)/Apache-Rails-Passenger_App_Server_(v13_Infinity)_-_Tutorial

ServerTemplate built on this cookbook can be combined in two modes:

1 - For apps with bundler support, add the "install_required app gems" recipe,
and "run_custom_rails_commands" for migration commands

2 - For apps without bundler support, add "install_custom_gems" recipe, and
"run_custom_rails_commands" for migration commands

Mix these recipes in any way to satisfy project requirements.

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs you can find in metadata.rb cookbook file.

###### General attributes

* `node[:app_passenger][:rails_spawn_method]` -
  The spawn method used by the passenger.
* `node[:app_passenger][:apache][:serve_local_files]` -
  Used to enable/disable the serve of any existing local files.
* `node[:app_passenger][:deploy_dir]` -
  Path in the specified repository where application code will be pulled from.
* `node[:app_passenger][:ruby_gem_base_dir]` -
  Path to Ruby gem directory.
* `node[:app_passenger][:gem_bin]` -
  Path to Ruby gem bin directory.
* `node[:app_passenger][:ruby_bin]` -
  Path to Ruby bin directory.
* `node[:app_passenger][:project][:environment]` -
  The environment of the rails application.
* `node[:app_passenger][:project][:gem_list]` -
  A list of additional gems required for rails application.
* `node[:app_passenger][:project][:custom_cmd]` -
  A list of rake commands required for rails application initialization.

###### Platform dependent

* `node[:app][:user]` - Apache user. Required for changing owner of created
project dirs.

### Templates:

* `basic_vhost.erb` - Configuration for apache vhost file used in the
  `app::setup_vhost` recipe and defined in `:setup_vhost` action of the
  `app_passenger` LWRP.
* `database.yml.erb` - Configuration for project database connection config file
  used in the `app::setup_db_connection` recipe and defined in
  `:setup_db_connection` action of the `app_passenger` LWRP.
* `rails_env.erb` - Template for bash script which will set up ENV for the rails
  project used in the `app::setup_db_connection` recipe and defined in
  `:setup_db_connection` action of the `app_passenger` LWRP.

### LWRPs:

`app_passenger` Lightweight provider is defined in the providers/default.rb
file, it contains source for the following actions:

* `:install`
* `:setup_vhost`
* `:start`
* `:stop`
* `:reload`
* `:restart`
* `:code_update`
* `:setup_db_connection`

For more info about these actions, please see the `app` cookbook README.

For normal operations it requires "app" resource which will act as the interface
to all `app_passenger` provider logic.

##### Actions

* `:install` - Install packages required for application server setup.
* `:setup_vhost` - Set up apache vhost file with passenger module directives
  included.
* `:start` - Start sequence for Passenger application server.
* `:stop` - Stop sequence for Passenger application server.
* `:reload` - Reload sequence for Passenger application server.
* `:restart` - Restart sequence for Passenger application server.
* `:code_update` - Perform project source code update/download using user
  selected "repo" LWRP. Set up logrotate configuration.
* `:setup_db_connection` - Perform project config/database.yml database
  connection configuration.
  The driver type is specified as 'ruby' and the db_<provider> cookbook's
  `install_client_driver` action performs necessary steps to install the
  database adapter.

##### Usage Example:

For usage examples please see corresponding section in `app` cookbook README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
