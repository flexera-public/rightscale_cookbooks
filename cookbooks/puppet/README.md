# RightScale Puppet Master and Client Cookbook

## DESCRIPTION:

This cookbook provides recipes for setting up and running the Puppet Client.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage

* Tested on the following RightImages: CentOS 6.4, Ubuntu 12.04

* Tested Puppet Client version 2.7.13-1

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.
* `rightscale`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* When using a RightScale ServerTemplate, place `puppet::install_client`
  recipe into your runlist to setup the Puppet Client. Set the address to
  connect to the Puppet Master.
* Use the `puppet::setup_client_monitoring` recipe to add Puppet Client
  monitoring options to your dashboard "Monitoring" tab.

For more info see: [Release Notes](http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/v13.4#Puppet_Client_\(v13.4\))

## DETAILS:

### General

The cookbook installs the Puppet Client with needed configuration for CentOS and
Ubuntu.

### Attributes:

These are the settings used in recipes and templates. Default values are noted.
* `node[:puppet][:client][:version]`-
  The package version. Default: "2.7.13-1"
* `node[:puppet][:client][:puppet_master_address]`-
  Enter the address to connect to the remote Puppet Master.
* `node[:puppet][:client][:puppet_master_port]`-
  The port to connect to the remote Puppet Master. Default: "8140"
* `node[:puppet][:client][:node_name]`-
  Name which will be used to authenticate the Client on the Puppet Master.
  Instance FQDN will be used if nothing is specified.
* `node[:puppet][:client][:environment]`-
  The environment type for the Puppet Client configs.

### Templates:

* `puppet_client.conf.erb`-
  The Puppet Client configuration file. Used in `puppet::install_client` recipe.
* `collectd_puppet_client.erb`-
  Collectd configuration file. Used in `puppet::setup_monitoring` recipe.
* `collectd_puppet_client_stats.erb`-
  Puppet Client monitoring plugin. Used in `puppet::setup_monitoring` recipe.

### Usage Example:

## Requery the Puppet Master

* `puppet::reload_agent`
  This recipe is used in the operational phase only. If the Puppet Master is
  not configured to autosign client certificate, user needs to sign it manually
  and run this recipe.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
