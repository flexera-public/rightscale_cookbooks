README.md template

# RightScale XXX Cookbook

## DESCRIPTION:

Replace this text with a high-level overview of what this cookbook configures
or manages. Don't go into too much detail here, save that for the 'details'
section below.

#### Example:

This cookbook provides abstract 'repo' resource for managing code download from
GIT, SVN or ROS code repositories.

## REQUIREMENTS:

Replace this text with a description of cookbook requirements:

* What user will have to add to template to make recipes from this cookbook work
  correctly?
* What OSs does this support?
* Is this cloud specific? If so, which clouds?

#### Example:

* One of 'repo' provider: `repo_git`, `repo_svn` or `repo_ros` cookbooks must be
  present in your cookbook repository ROS implementation depends on the
  `rightscale::install_tools` recipe.
* Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

List any known limitation here that might affect functionality and usability.
Be sure to include a ticket number.

#### Example:

Currently only primary backups to Remote Object Storage (ROS) are supported for
KVM hypervisors (w-1234).

## SETUP/USAGE:

Describe minimum required set of actions required for correct work of recipes
from this cookbook.

#### Example:

Place the `app_tomcat::default` recipe into your runlist to setup the
application server. When using a RightScale ServerTemplate, this will also
automatically add the common attributes to your ServerTemplate inputs. Set
'jdbc/ConnDB' as your datasource name to set up database connection with the
application server.

## DETAILS:

### General

Replace this text with a common information about cookbook elements and anything
else that users need to know in order to properly use this cookbook.

#### Example:

This cookbook is intended to be used in conjunction with cookbooks that contain
Lightweight Providers which implement the `repo` interface. See the
RightScale repo_git cookbook for an example.

### Attributes:

Describe cookbook attributes here.

Please create description only for "internal" attributes here e.g those which
have no inputs. 'set' directive in attributes/default.rb cookbook file.

You can create subsections to split attributes by their specs Ex:
`General` `Apache common`, `Apache worker` etc.

#### Example:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs you can find in the `metadata.rb` cookbook
file.

* `node[:apache][:dir]` - Location for the Apache configuration
* `node[:apache][:log_dir]` - Location for Apache logs
* `node[:apache][:prefork][:startservers]` - initial number of server processes
  to start. Default is 16.
* `node[:apache][:prefork][:minspareservers]` - minimum number of spare server
  processes. Default 16.

### Templates:

Describe cookbook templates here.

Format is:

template name - description - recipe/recipes where this template is called.

Add link to the production templates that use this cookbook.

#### Example:

__server.rb.erb__

Configuration for the server and server components used in the
`chef-server::rubygems-install` recipe.

### Definitions:

Use this section only if your cookbook contains definitions.

Give complete description of definition functionality and provide examples of
how it's used in recipes.

#### Example:

__apache\_module__

Enable or disable an Apache module in
`#{node['apache']['dir']}/mods-available` by calling `a2enmod` or
`a2dismod` to manage the symbolic link in
`#{node['apache']['dir']}/mods-enabled`. If the module has a configuration
file, a template should be created in the cookbook where the definition is
used. See __Examples__.

Parameters:

* name - Name of the module enabled or disabled with the `a2enmod` or
  `a2dismod` scripts.
* enable - Default true, which uses `a2enmod` to enable the module. If false,
  the module will be disabled with `a2dismod`.
* conf - Default false. Set to true if the module has a config file, which will
  use `apache_conf` for the file.
* filename - specify the full name of the file, e.g.

Examples:

Enable the ssl module, which also has a configuration template in
`templates/default/ssl.conf.erb`.

    apache_module "ssl" do
      conf true
    end

### Libraries-helpers:

Use this section only if your cookbook contains any libraries. Give complete
description of library purpose and functionality. Provide examples of how it is
used in recipes.

#### Example:

__RightScale::App::Helper.bind_ip(private_ips = [], public_ips = [])__

Return the IP address of the interface that this application server listens on.

Parameters:

* `private_ips(Array)::` List of private ips assigned to the application
  server
* `public_ips(Array)::` List of public ips assigned to the application
  server

Returns:

`String::` IP Address

Raise:

`RuntimeError::` If nether a valid private nor public ip can be found

### LWRPs:

Use this section only if your cookbook contain resources and/or providers.

* Give common information about existing LWRPs in your cookbook, and point user
  to common info about RightScale LWRPs.

#### Example:

The 'db' interface is defined by a Lightweight Resource, which can be found
in the resources/default.rb file.

For now we have:

* `db_mysql` https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/db_mysql
* `db_postgres` https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/db_postgres

Each of them contain implementation of corresponding db_* LightWeight Provider
which can be called using this resource.

For more information about Lightweight Resources and Providers (LWRPs), please
see: [Chef Cookbooks Developer Guide][LWRP]

[LWRP]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/08-Chef_Development/Lightweight_Resources_and_Providers_(LWRP)

* Describe resource purpose and functionality. Describe its attributes

#### Example:

Common attributes

`:destination` - Path to where project repo will be pulled
`:repository` - Repository Url
`:revision` - Remote repo Branch or revision

* Give provider usage examples.

#### Example:

__Update Action__

To open a local port to all servers with a given tag use:

    sys_firewall "Open this database's ports to all appservers" do
      machine_tag "appserver:active=true"
      port 3306
      enable true
      action :update
    end

This can be useful as a server is booting to open up access for multiple systems
at once.

__Update Request Action__

To request all servers with a given tag close a port to a given IP address use:

    sys_firewall "Request all appservers close ports to this loadbalancer" do
      machine_tag "loadbalancer:app=www"
      port 8000
      enable false
      ip_addr node[:cloud][:private_ips][0]
      action :update_request
    end

This can be useful when decommissioning a running server that had previously
requested ports opened.

* All tag based actions are scoped to the deployment.

# LICENSE:

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.
