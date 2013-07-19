# RightScale Cookbook

## DESCRIPTION:

This cookbook provides base recipes used to set up services used by the
RightScale Cloud Management Platform.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see the `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP:

The `rightscale::default` recipe performs common server configuration
steps such as enabling monitoring on an instance so that graphs can be
displayed in the RightScale Dashboard.

The `rightscale::install_tools` recipe installs the
`rightscale_tools` gem which provides tools for dealing with databases,
volumes, and remote object storage providers.

The `rightscale::setup_cloud` recipe performs cloud specific setup such
as setting up the monitoring agents for the Rackspace Managed Open cloud.

The `rightscale::setup_security_updates` recipe configures
the package manager to apply security updates by unfreezing the
server's repositories. On apt based systems this unfreezes the security
repository. On yum based systems this unfreezes all repositories except
the RightScale-Epel repository. Runs if the `rightscale/security_updates`
input is set to "enable", otherwise this action is skipped.
Note: once security updates are enabled they can not be disabled.

The `rightscale::setup_security_update_monitoring` recipe installs a collectd
plugin that will monitor available security updates. This plugin
is always installed regardless of the input `rightscale/security_updates`.
This plugin will add a tag `rs_monitoring:security_updates_available=true` if
there are any security updates available. This tag will be removed once the
security updates are applied.

The `rightscale::do_security_updates` recipe updates a server with
the latest available security patches. Non-security related software updates
are not installed. It runs as the last boot script to ensure a new
server has all available security updates applied. Runs if the
`rightscale/security_updates` input is set to "enable", otherwise
this action is skipped. Once the security updates are applied and if a reboot is
required the `rs_monitoring:reboot_required=true` tag is added to the server.
This tag is removed when the server reboots.
Note: once security updates are enabled they can not be disabled.

The `rightscale::install_rightimage_extras` recipe installs the package
`rightimage-extras`.  This ensures that all non-rightscale created images
have the same packages as a RightImage does.

The `rightscale::setup_redhat` recipe registers the server with [Red Hat Network
Classic](https://access.redhat.com/site/articles/63269) when the server is on
a redhat platform and the inputs `rightscale/redhat/username` and
`rightscale/redhat/password` are set.

## USAGE:

### Update a server with latest security updates

1. Prior to launching a server set the advanced input
   `rightscale/security_updates` to "enable"
2. When the server is operational all current security updates are applied.
3. Apply security updates using:

    "rightscale::do_security_updates"

   to bring the server to the latest patch level. Reboot the server if tag
   `rs_monitoring:reboot_required=true` is set.

### Enable security updates on a running server

1. On a running a server set the advanced input `rightscale/security_updates`
   to `enable`
2. Setup the package manager for security updates using:

    "rightscale::setup_security_updates"

   to unfreeze the security related repositories.
3. Setup monitoring for available security updates using:

    "rightscale::setup_security_update_monitoring"

   for the monitoring and alerts to work properly.
4. To update the server with the latest security updates follow the steps above.

## DETAILS:

### Definitions:

#### rightscale_enable_collectd_plugin

* Accepts only one parameter "name" which is the name of the collectd plugin to
  enable.
* The plugin name is added to `node[:rightscale][:plugin_list_array]` which is
  used to create the list of plugins in the `/etc/collectd/collectd.conf` file.
* The `node[:rightscale][:plugin_list_array]` will have any plugins listed
  in the `node[:rightscale][:plugin_list]` merged into it, which
  supports any legacy recipes, as well as allow the input to be manipulated in
  the RightScale Dashboard.

Syntax:

    rightscale_enable_collectd_plugin "curl_json"

#### rightscale_monitor_process

* Accepts only one parameter, "name" which is the name of the process to
  monitor.
* The process name is added to the `node[:rightscale][:process_list_array]`
  which is used to create the list of processes in the
  `/etc/collectd/conf/processes.conf` file.
* The `node[:rightscale][:process_list_array]` will have any processes
  listed in `node[:rightscale][:process_list]` merged into it, which supports
  any legacy recipes, as well as allow the input to be manipulated in the
  RightScale Dashboard.

Syntax:

    rightscale_monitor_process "nginx"

#### rightscale_marker

* Accepts only one parameter, "location" which can be used to denote
  the :start or :end of a recipe. It can also be :begin, :stop, and
  the string versions. The default value for this parameter is :begin.
* Used to log the start and end of a recipe using the `Chef::Log.info` Chef
  Logger class.
  Should be added at the beginning of a recipe. No need for marking the end of
  the recipe.
* Example:
  `================= cookbook_name::recipe_name : START/END ===================`

Syntax:

    rightscale_marker
    ...

### Resources:

#### rightscale_server_collection

The server collection resource finds a set of servers in a deployment with a set
of tags. The `tags` attribute specifies the tag or tags to search for (if
multiple tags are specified, servers with any of the tags will match) and the
optional `mandatory_tags` attribute specifies tags that need to also
appear on the servers, it will wait one minute for the `mandatory_tags`
to appear, which can be overridden with the `timeout` attribute.

Syntax:

    rightscale_server_collection "rightscale_servers" do
      tags "rs_login:state=active"
      mandatory_tags "server:uuid=*"
    end

NOTE: The `secondary_tags` attribute is deprecated in favor of `mandatory_tags`.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
