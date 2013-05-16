# RightScale Puppet Server and Client Cookbook

## DESCRIPTION:

This cookbook provides recipes for setting up and running a Puppet Client.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage

* Tested on the following RightImages: CentOS 6.3, Ubuntu 12.04

* Tested Puppet Client version 2.7.13-1

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.
* `rightscale`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* When using a RightScale ServerTemplate, place `puppet::install_client`
  recipe into your runlist to setup the Puppet Client. Set the address to
  connect to the Puppet Server.

For more info see: [Release Notes](http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/v13.4#Puppet_Client_\(v13.4\))

## DETAILS:

### General

The cookbook installs the Puppet Client with needed configuration for CentOS and
Ubuntu.

### Attributes:

These are the settings used in recipes and templates. Default values are noted.
* `node[:puppet][:client][:version]`-
  The package version. Default: "2.7.13-1"
* `node[:puppet][:client][:puppet_server_address]`-
  Enter the address to connect to the remote Puppet Server.
* `node[:puppet][:client][:puppet_server_port]`-
  The port to connect to the remote Puppet Server. Default: "8140"
* `node[:puppet][:client][:node_name]`-
  Name which will be used to authenticate client on the remote Puppet Server.
  if nothing specified -instance fqdn will be used.
* `node[:puppet][:client][:environment]`-
  The environment type for the Puppet Client configs. Default: "nil"

### Templates:

* `puppet_client.conf.erb`-
  The Puppet Client configuration file. Used in `puppet::install_client` recipe.
* `collectd_puppet_client.erb`-
  Collectd configuration file. Used in `puppet::setup_monitoring` recipe.
* `collectd_puppet_client_stats.erb`-
  Puppet Client monitoring plugin. Used in `puppet::setup_monitoring` recipe.

### Usage Example:

## The Client certificate signing.

* `puppet::reload_agent`
  This recipe is used in the operational phase only. If the Puppet Server is
  not configured to autosign client certificate, user needs to sing it manually
  and run this recipe.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
