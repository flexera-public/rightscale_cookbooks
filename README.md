# RightScale Cookbooks

Welcome to the RightScale cookbooks -- your infrastructure, codified!

## OVERVIEW:

These cookbooks are a set of interchangeable parts for your infrastructure
written using the open-source systems integration framework called
[Chef](http://wiki.opscode.com/display/chef/About).

They can be used without modification by mixing-and-matching recipes or as a
starting point for your own creations. These cookbooks are built for use within
RightScale's [ServerTemplates](http://support.rightscale.com/12-Guides/Dashboard_Users_Guide/Design/ServerTemplates/Concepts/About_ServerTemplates)
to create [3-tier deployment architectures for High Availability in the
cloud](http://support.rightscale.com/ServerTemplates/v12.11_LTS/Supplemental/3_Tier_Deployment_Setup_%28PHP%29#Overview).
These deployments fit the requirements for many auto-scaling HA
deployments, however no single infrastructure need is exactly the same -- the
source code is provided here to give you the control over how much (or how
little) customization you want.

These are *your* cookbooks!

As a good starting point, the **COOKBOOK LIST** section below will give you a
summary of what each cookbook does. From there, each cookbook has its own README
file that goes into depth about what it does and how to use it -- this is the
information you need if you want to create a runlist or ServerTemplate by mixing
and matching recipes.

For a deeper understanding of how to navigate and find things in these
cookbooks, be sure to take a look at the **DESIGN DETAILS** section.
This will give you an intro into some of the design patterns and conventions
used throughout this collection. NOTE: This section is not for the faint of
heart as it deals with some advanced Chef topics.

Whether you are looking to write your own cookbooks or to just make some minor
tweaks to these, please see the **CUSTOMIZATION** section for some best
practices regarding overriding vs. forking.  We are happy if you modify and make
these cookbooks your own, however, if you ever implement a change that you think
will be useful to others or would like to see the change folded in to next
release, then please feel free to contribute it back. For more information about
how to do this see the guidelines under the **CONTRIBUTING** section.

Some of these cookbooks leverage Chef resources that are specific to the
RightScale Platform -- these resources are used for such things as managing
machine tags associated with the node, running recipes in parallel and the
ability to trigger a "remote recipe" to run on one node to from another. For
more information, please see the **RIGHTSCALE RESOURCES** section below.

These cookbooks have been tested on multiple clouds and multiple operating
systems using ServerTemplates on the RightScale Cloud Management Platform.


## COOKBOOK LIST:

<dl>
  <dt>app</dt>
  <dd>RightScale application server management cookbook. This cookbook contains
 recipes that are generally applicable to all applications.</dd>

  <dt>app_django</dt>
  <dd>Cookbook provides Apache + Django implementation of the 'app' Lightweight
 Resource Provider (LWRP). Installs and configures an Apache + Django
 application server.</dd>

  <dt>app_passenger</dt>
  <dd>Cookbook provides an Apache + Passenger implementation of the 'app' LWRP.
 Installs and configures an Apache + Passenger application server.</dd>

  <dt>app_php</dt>
  <dd>Cookbook provides Apache + PHP implementation of the 'app' LWRP. Installs
  and configures, Apache + PHP application server.</dd>

  <dt>app_tomcat</dt>
  <dd>Cookbook provides Tomcat application server implementation of the 'app'
  LWRP.  Installs and configures, Tomcat application server.</dd>

  <dt>block_device</dt>
  <dd>This cookbook provides the building blocks for Multi-Cloud backup/restore
  support.</dd>

  <dt>db</dt>
  <dd>This cookbook provides a set of database recipes used by the RightScale
  Database Manager ServerTemplates. This cookbook does not contain a specific
  database implementation, but generic recipes that use the LWRP interface.</dd>

  <dt>db_mysql</dt>
  <dd>Provides the MySQL implementation of the 'db' resource to install and
  manage MySQL database stand-alone servers and clients.</dd>

  <dt>db_postgres</dt>
  <dd>Provides the PostgreSQL implementation of the 'db' resource to install and
  manage PostgreSQL database stand-alone servers and clients.</dd>

  <dt>lamp</dt>
  <dd>This is a basic all-in-one LAMP (Linux, Apache, MySQL, PHP) cookbook
  designed to work in a hybrid cloud setting.</dd>

  <dt>lb</dt>
  <dd>This cookbook provides a set of load balancer recipes used by the
  RightScale Load Balancer ServerTemplates. This cookbook does not contain a
  specific load balancer implementation, but generic recipes that use the LWRP
  interface.</dd>

  <dt>lb_clb</dt>
  <dd>RightScale load balancer cookbook for Rackspace Cloud Load Balancing
  (CLB). This cookbook provides recipes for attaching and detaching application
  servers to and from an existing Rackspace Cloud Load Balancer (CLB).</dd>

  <dt>lb_elb</dt>
  <dd>RightScale load balancer cookbook for AWS Elastic Load Balancer (ELB).
  This cookbook provides recipes for attaching and detaching application servers
  to and from an existing AWS Elastic Load Balancer (ELB).</dd>

  <dt>lb_haproxy</dt>
  <dd>RightScale load balancer cookbook for Apache/HAProxy. This cookbook
  provides recipes for setting up and running an Apache/HAProxy load balancer
  server as well as recipes for attaching and detaching application
  servers.</dd>

  <dt>logging</dt>
  <dd>This cookbook provides a set of recipes used by the RightScale
  ServerTemplates to configure the logging service provider. This cookbook does
  not contain a specific logging server implementation but generic recipes that
  use the LWRP interface.</dd>

  <dt>logging_rsyslog</dt>
  <dd>Provides 'rsyslog' implementation of the 'logging' resource to configure
  'rsyslog' to log to a remote server or use default local file logging.</dd>

  <dt>logging_syslog_ng</dt>
  <dd>Provides 'syslog_ng' implementation of the 'logging' resource to
  configure 'syslog_ng' to log to a remote server or use default local file
  logging.</dd>

  <dt>memcached</dt>
  <dd>This cookbook provides a set of recipes used by the RightScale Memcached
  ServerTemplates to install and configure a Memcached server.</dd>

  <dt>repo</dt>
  <dd>This cookbook provides abstract 'repo' resource for managing code download
  from Git, Subversion or Remote Object Store (ROS) code repositories.</dd>

  <dt>repo_ftp</dt>
  <dd>Provides the FTP implementation of the 'repo' resource to manage source
  code downloaded from FTP.</dd>

  <dt>repo_git</dt>
  <dd>Provides the Git implementation of the 'repo' resource to manage source
  code download from Git repositories.</dd>

  <dt>repo_ros</dt>
  <dd>Provides the Remote Object Store implementation of the 'repo' resource to
  manage the downloading of source code from Remote Object Store repositories
  such as Amazon S3, Rackspace Cloud Files, and OpenStack Swift.</dd>

  <dt>repo_rsync</dt>
  <dd>Provides the rsync implementation of the 'repo' resource to manage source
  code downloaded via rsync.</dd>

  <dt>repo_svn</dt>
  <dd>Provides the Subversion implementation of the 'repo' resource to manage
  source code download from Subversion repositories.</dd>

  <dt>rightscale</dt>
  <dd>Base recipes used to set up services used by the RightScale Cloud
  Management Platform.</dd>

  <dt>sys</dt>
  <dd>Provides RightScale system utilities.</dd>

  <dt>sys_dns</dt>
  <dd>This cookbook provides a set of dynamic DNS recipes used by RightScale
  ServerTemplates including Database Manager ServerTemplates. Cookbook currently
  supports DNSMadeEasy, DynDns, CloudDNS, and Amazon Route53 DNS service
  providers.</dd>

  <dt>sys_firewall</dt>
  <dd>RightScale firewall cookbook. This cookbook provides a LWRP for managing
  access to multiple servers in a deployment using machine.</dd>

  <dt>sys_ntp</dt>
  <dd>This cookbook provides a recipe for setting up time synchronization using
  NTP.</dd>

  <dt>web_apache</dt>
  <dd>This cookbook installs and configures an Apache2 web server.</dd>
</dl>

## DESIGN DETAILS:

Many of the cookbooks use the same overarching design and conventions.

### Navigating the source

In the cookbooks, resource calls in recipes can be calls to built-in resources,
light weight resources, or definitions. Built-in resources are part of Chef and
are documented in [Chef Resources](http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources).
Light weight resources are often named the same as one of the cookbooks, but
several are just prefixed with the cookbook name such as
`rightscale_server_collection`; they are defined in the
`resources/` directory (for example the `sys_firewall` resource
is defined in `cookbooks/sys_firewall/resources/default.rb` and the
`rightscale_server_collection` resource is defined in
`cookbooks/rightscale/resources/server_collection.rb`. Light weight
resources have accompanying providers; these are located in the
`providers/` subdirectories of cookbooks and will either be in the same
cookbook as the resource or, in the case of the Abstract Cookbooks (see below)
pattern, in the each of the implementation cookbooks. In the RightScale
cookbooks, definitions are prefixed with the cookbook name; they are located in
the `definitions/` directory in the cookbook (for example
`rightscale_marker` is defined in
`cookbooks/rightscale/definitions/rightscale_marker.rb`).

### Dependency Resolution

Typically cookbooks depend on other cookbooks for resources, providers, and
definitions. If a dependency is not specified in the `metadata.rb` for a
cookbook, its recipes may load without the cookbooks they depend on and will
fail to execute. In addition, there are also resources that are set up in
recipes from other cookbooks; when setting up a ServerTemplate with these kinds
of dependencies, the recipes for those dependent cookbooks need to appear
earlier in the boot scripts. This pattern is explained in "The Default Recipe"
and "Abstract Cookbooks and LWRPs" below.

### The Default Recipe

Some of our cookbooks contains a `default.rb` recipe. In this recipe
we install packages, setup configurations and initialize Chef resources that
other cookbooks may depend on. We also setup any prerequisites and attributes
that might be needed for the other recipes in the cookbook. Be sure to add the
default recipe to your ServerTemplate boot scripts or your Role's runlist before
running any other of the recipes in the cookbook. You should also add the
default recipe of the cookbooks that your cookbook depends on.

For more information, please see: [What is RightScale's Default
Pattern](http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-RightScale_Support_of_Chef/RightScale_Cookbook_Design_Conventions#What_is_RightScale's_Default_Pattern.3f).


### Abstract Cookbooks and LWRPs

Another convention used in the RightScale cookbooks is the *Abstract* *Cookbook*
pattern. Typically, this pattern is used to distinguish and decouple server and
client installation.

In this pattern the *abstract* cookbook contains a resource that defines a set
of general actions (for example initializing, backing up, and restoring a
database) and a set of recipes that use these actions. The `default.rb`
recipe in *abstract* cookbooks sets up the provider and all provider-specific
inputs, and installs the client. The `install_server.rb` recipe sets all
generic server inputs, includes the `default.rb` recipe and installs the
server. The *concrete* cookbooks contain providers that implement the actions
for a specific variety of the abstract cookbook (for example a MySQL or
PostgreSQL database) and a `setup_server.rb` recipe that sets up server
specific inputs and hard codes the provider name and version of the server.

This differs slightly from the typical use of Chef Resources and Providers,
where both light weight resources and providers are typically contained in the
same cookbook.

For an example of an abstract cookbook, please see the "db" cookbook. The
corresponding concrete cookbooks are "db_mysql" and "db_postgres".

To group, abstract cookbooks with their concrete cookbooks, each concrete
cookbook is prefixed with the name of the abstract cookbook. This can be seen
repeated throughout our collection with groupings such as "app", "db", "lb",
"logging", "repo", etc.

The only grouping that is currently an exception is the "sys" grouping of
cookbooks. These are distinct system related cookbooks.

For more information, please see: [Abstract Cookbook
Pattern](http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-RightScale_Support_of_Chef/RightScale_Cookbook_Design_Conventions#Abstract_Cookbook_Pattern)

### Definitions

Definitions are often used for common sequences of resources in recipes that are
used in multiple recipes but do not warrant a separate recipe that could be
called with `include_recipe` (for example the
`db::do_primary_backup` and `db::do_secondary_backup` recipes use
the `db_do_backup` definition that uses a set of resources from the
`db` and `block_device` cookbooks to perform a database backup).

In addition to housing reusable recipe snippets used within the cookbook, we
also use definitions as external methods that other cookbooks can call.
For example, `rightscale_logrotate_app` which allows other cookbooks to
add their logrotate configurations while deferring details of logrotate to the
`rightscale` cookbook.

In the RightScale cookbooks, definitions are named with the cookbook name as a
prefix so you can easily find which cookbook a definition comes from (for
example the `rightscale_marker` definition is defined in the
`rightscale` cookbook and the `db_do_backup` definition is defined
in the `db` cookbook).


#### rightscale_marker

All of the recipes in the RightScale cookbooks begin with a single call to the
`rightscale_marker` definition which is defined in the
`rightscale` cookbook. It is used for better readability and debugging of
the logs of Chef recipe runs. The definition prints log messages with the
cookbook and recipe name showing the beginning and end of the recipe run. Note
that there is no need for marking the end of a recipe.

    12:12:42: *******************************************
    12:12:42: *RS>  Running rightscale::default   *******
    ...

Including these log lines at the beginning and end of every recipe run allows
grouping of recipe logs in "Audit Entries" tab in the RightScale UI.

If you include the `rightscale` cookbook as dependency of your own
cookbook, you can use the `rightscale_marker` definition as well:

    rightscale_marker
    ...

## RIGHTSCALE RESOURCES:

RightScale provides some custom Chef resources that are available when running a
RightImage launched from the RightScale platform. These resources include
`remote_recipe`, `right_link_tag`, `server_collection`, `rs_shutdown`, and
`executable_schedule`.

For documentation, see [Chef Resources](http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources).

## CUSTOMIZATION:

If you need to change the behavior of the RightScale cookbooks in a way that
cannot be achieved using the inputs or in your own cookbooks, you can use a
cookbook override. For more information see [Override Chef Cookbooks](http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/08-Chef_Development/Override_Chef_Cookbooks).

## DEVELOPMENT:

The dependencies for working with the RightScale Cookbooks can be installed with
Bundler:

    bundle install

### Rake Tasks:

* There are several Rake tasks to check the cookbooks with [Foodcritic](http://acrmp.github.com/foodcritic/)
  (Foodcritic currently only works with Ruby 1.9.2 and higher):
  * `foodcritic` Runs Foodcritic with the standard suite of rules
  * `foodcritic_correctness` Runs Foodcritic with just the correctness rules
  * `foodcritic_syntax` Runs Foodcritic with just the syntax rules

## CONTRIBUTING:

Contributors to the RightScale cookbooks need to agree to and sign the
[RightScale Contributors Agreement](https://rightscale.echosign.com/public/hostedForm?formid=3SMKS95X3F5G3S)
before contributions will be accepted.

To contribute changes back to the RightScale cookbooks:

1. Fork the repository on GitHub.
2. Make changes in your forked repository.
3. Rebase from the master branch.
4. Make a pull request.

## LICENSE:

**RightScale Cookbooks**

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.

Maintained by the RightScale White Team
