# RightScale App Django Cookbook

## DESCRIPTION:

* This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).
* Cookbook provides Apache + Django implementation of the 'app' LWRP.
* Installs and configures, Apache + Django application servers.

## REQUIREMENTS:

* Requires ["app" Lightweight resource cookbook][app] or your own implementation
  of the "app" resource. See "app" cookbook README for details.
* Requires a VM launched from a RightScale managed RightImage
* Tested on CentOS 6.2 RightImage
* Tested on Ubuntu 12.04 RightImage

[app]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/app

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `rightscale`
* `web_apache`
* `repo`
* `logrotate`
* `app`
* `db`
* `python`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place `app_django::setup_server_1_4` recipe into your runlist to set
  up the application server specific attributes. This sets up the app provider
  and version.
* Place `app::install_server` recipe after setup_server recipe to install
  the application server.

## DETAILS:

### General:

The `app_django` cookbook will install and set up an Apache + Django
application server configured to connect with a MySQL or Postgres database
server.
Set db/provider_type input in RightScale ServerTemplate to choose database
provider. Place `db::default` recipe before application server installation
to install the database client.

__Apache__

Server version: Apache/2.2.15

Server built: Feb 13 2012 22:31:42

__Django__

Django version 1.4

Python version 2.6.6 (2012-06-18) (x86_64-linux), Pip version 1.1

also:
* `Custom python command input`
* `Bundler support`
* `Input for user defined python module installation`
* `Application code installation from remote git, svn or Remote Object Store
  (ROS) location`
* `MySQL or Postgres database connection file configuration`
* `Automatic application vhost file configuration`
* `Automatic logrotate file configuration for Apache logs`

For more info see: [Release Notes][Notes] (Section 'Django App Server' under
ServerTemplates)

[Notes]: http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/current

Please checkout the tutorial: [Django App Server][Tutorial]

[Tutorial]: http://support.rightscale.com/ServerTemplates/Infinity/ST/Django_App_Server_Beta_(v13_Infinity)/Django_App_Server_Beta_(v13_Infinity)_-_Tutorial

ServerTemplate built on this cookbook can be combined in two modes:

1 - For apps with bundler support, keep the "requirements.txt" file under
application ROOT directory, and "run_custom_python_commands" for migration
commands

2 - For apps without bundler support, provide package(s) name as user input
while server launch, and "run_custom_python_commands" for migration commands

Note: In operational mode to install additional python packages for Django app
server, provide package(s) name as user input and re-run the `app::default` boot
recipe.

Mix these recipes in any way to satisfy project requirements.

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs you can find in metadata.rb cookbook file.

###### General attributes

* `node[:app_django][:module_dependencies]` - Modules required for Apache.
* `node[:app_django][:app][:debug_mode]` - Django application debug mode.
* `node[:app_django][:apache][:serve_local_files]` - Used to enable/disable the
  serve of any existing local files.
* `node[:app_django][:deploy_dir]` - Path in the specified repository where
  application code will be pulled from.
* `node[:app_django][:pip_bin]` - Path to Python pip bin directory.
* `node[:app_django][:python_bin]` - Path to Python bin directory.
* `node[:app_django][:project][:opt_pip_list]` - A list of additional python
  packages, required for django application
* `node[:app_django][:project][:custom_cmd]` - A list of python commands
  required for django application initialization.

### Templates:

* `apache_mod_wsgi_vhost.erb` - Configuration for apache vhost file used in the
  `app::setup_vhost` recipe and defined in `:setup_vhost` action of the
  `app_django` LWRP.
* `wsgi.py.erb` - Configuration for Apache-Django WSGI config file used in the
  `app::setup_vhost` recipe and defined in `:setup_vhost` action of the
  `app_django` LWRP.
* `settings.py.erb` - Rename django "settings.py" file under app root to
  "settings_default.py", configure new "settings.py" file for project database
  connection used in the `app::setup_db_connection` recipe and defined in
  `:setup_db_connection` action of the `app_django` LWRP.

### LWRPs:

`app_django` Lightweight provider is defined in the providers/default.rb file,
it contains source for the following actions:

* `:install`
* `:setup_vhost`
* `:start`
* `:stop`
* `:restart`
* `:reload`
* `:code_update`
* `:setup_db_connection`

For more info about these actions, please see the `app` cookbook README.

For normal operations it requires "app" resource which will act as the interface
to all `app_django` provider logic.

##### Actions

* `:install` - Install packages required for application server setup.
* `:setup_vhost` - Set up apache vhost file with wsgi module directives
  included.
* `:start` - Start sequence for Django application server.
* `:stop` - Stop sequence for Django application server.
* `:reload` - Reload sequence for Django application server.
* `:restart` - Restart sequence for Django application server.
* `:code_update` - Perform project source code update/download using user
  selected "repo" LWRP. Set up logrotate configuration.
* `:setup_db_connection` - Perform project settings.py database connection
  configuration. The driver type is specified as 'python' and the db_<provider>
  cookbook's `install_client_driver` action performs necessary steps to install
  the database adapter.

##### Usage Example:

For usage examples please see corresponding section in `app` cookbook README.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
