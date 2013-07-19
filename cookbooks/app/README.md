# RightScale App Cookbook

## DESCRIPTION:

RightScale's cookbook for application server management.

This is an abstract cookbook that defines the recipes and interface to
application provider cookbooks. It is not a standalone cookbook and must be
used in conjunction with an application provider cookbook (i.e.
`app_php`, `app_tomcat`, `app_passenger`, `app_django` or a user created
application provider).

More detailed information can be found in the descriptions for each recipe in
the cookbook. `app::*`.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage
* Requires a corresponding app provider cookbook

## COOKBOOKS DEPENDENCIES:
Please see `metadata.rb` file for the latest dependencies.

* `sys_firewall`
* `rightscale`
* `repo`
* `app_php`
* `app_passenger`
* `app_tomcat`
* `app_django`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP:

In order to use App resource, you must create corresponding providers in your
app server cookbook. For examples, see `app_passenger`, `app_php`, `app_django`
or `app_tomcat` cookbooks.

You must define app attributes which will be used in the initialized
`app[default]` resource.

Required attributes:

    node[:app][:provider] = "app_passenger"

Recommended:

    node[:app][:destination]
    node[:app][:port]
    node[:app][:root]
    node[:app][:database_name]
    node[:app][:database_user]
    node[:app][:database_password]
    node[:app][:database_server_fqdn]
    node[:app][:db_adapter]
    node[:app][:user]
    node[:app][:group]

More detailed descriptions of these attribute variables is located in the
resource file's description.

## USAGE:

1. Add the `app_*::default` recipe prior to the `app::default`
   recipe to define the provider.
2. Add the default recipe to tag your server as an appserver. This is used by
   servers (like databases) to identify their clients.
3. Add desired `app::do_*` recipes to your application server
   ServerTemplate.
4. Develop corresponding providers in your application server's cookbook.
5. Define required and recommended attributes in your application server's
   cookbook attributes file.

## DETAILS:

### General

This cookbook can only be used in conjunction with cookbooks that contain
Lightweight Providers which implement the 'app' interface. See the RightScale
`app_php` cookbook for an example.

Note: `app[default]` resource uses the "persist true" flag, which allows you to
save the created resource and its attributes in memory for future use.

This cookbook contains recipes that are required to connect your instance to
RightScale's "Load Balancer" ServerTemplates:

* `do_loadbalancers_allow`
* `do_loadbalancers_deny`
* `request_loadbalancer_allow`
* `request_loadbalancer_deny`

For more info please see: [Load Balancer Setups][Tutorial].

[Tutorial]: http://support.rightscale.com/ServerTemplates/Infinity/ST/Load_Balancer_with_HAProxy_(v13_Infinity)/Load_Balancer_with_HAProxy_(v13_Infinity)_-_Tutorial

### Attributes:

* `node[:app][:provider]` - Set a default provider.
* `node[:app][:port]` - Set a default port to listen on. Default: 8000
* `node[:app][:ip]` - IP to listen on. Default: First private IP
* `node[:app][:user]` - Application server user. Required for changing owner
  of created project dirs.
* `node[:app][:group]` - Application server group. Required for changing owner
  of created project dirs.

### Definitions:

__app\_add\_listen\_port__

Adds a port to the apache listen 'ports.conf' file and node attribute.

Create `node[:apache][:listen_ports]` - array of strings for the web server to
listen on.

This definition created specifically for the `apache2` cookbook at this time.

#### Example:

   app_add_listen_port php_port

### Libraries-helpers:

##### RightScale::App::Helper.vhosts(vhost_list)

Created to convert vhost names into an array from a comma-separated list.

__Parameters__

`vhost_list(Sting)::` Comma-separated list of virtual hosts.

__Returns__

`Array::` Array of vhosts

### LWRPs:

This cookbook provides the abstract `app` resource, which will act as
an "interface" for corresponding Lightweight app_* providers.

This includes `app_php`, `app_tomcat`, `app_passenger` and `app_django`
cookbooks. Each of them contains an implementation of the corresponding app__*
Lightweight Provider which can be called using this resource.

To avoid unexpected failures, the Provider persisted in this cookbook will act
as a cap if there is no other app_ Light Weight Provider implementation.

For more information about Lightweight Resources and Providers (LWRPs), please
see: [Lightweight Resources and Providers (LWRP)][LWRP].

[LWRP]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

##### App resource actions

All actions declared in this resource are intended to act as templates to typical
application server setup operations.

* `:install` - Install packages required for application server setup.
* `:setup_vhost` - Action designed to set up APP LWRP with common parameters
  required for apache vhost file.
* `:start` - Action designed to set up a user defined start sequence for
  the application server.
* `:stop` - Action designed to set up a user defined stop sequence for
  the application server.
* `:restart` - Action designed to set up a user defined restart sequence for
  the application server.
* `:reload` - Action designed to set up a user defined reload sequence for
  the application server.
* `:code_update` - Action designed to perform project source code
  update/download.
* `:setup_db_connection` - Action designed to perform database
  configuration file creation.
* `:setup_monitoring` - Action designed to set up and install required
  monitoring software.

##### App resource attributes

* `packages` - Set of installed packages
* `root` - Application root
* `port` - Application port
* `destination` - The path on the instance where the application code will be
  placed
* `database_name` - Name of the required database
* `database_user` - Database user
* `database_password` - Database password
* `database_server_fqdn` - Database server's fully qualified domain name (FQDN)
* `user` - App user
* `group` - Group the app user belongs to

##### Usage Examples:

Below are a few basic examples. More detailed examples of this resource use can
be found in the `do_*` and `setup_*` recipes in the cookbook.

    app "default" do
      persist true
      provider node[:app][:provider]
      packages node[:app][:packages]
      action :install
    end

    app "default" do
      database_name node[:app][:database_name]
      database_user node[:app][:database_user]
      database_password node[:app][:database_password]
      database_server_fqdn node[:app][:database_server_fqdn]
      action :setup_db_connection
    end

    app "default" do
      root node[:app][:root]
      port node[:app][:port].to_i
      action :setup_vhost
    end

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
