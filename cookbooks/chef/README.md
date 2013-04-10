# RightScale Chef Server and Client Cookbook

## DESCRIPTION:

This cookbook provides recipes for setting up and running a Chef Client.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage

* Tested on the following RightImages: CentOS 6.3, Ubuntu 12.04

* Tested Chef Client version 10.24.0-1

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.
* `rightscale`

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* When using a RightScale ServerTemplate, place `chef::install_client`
  and `chef::do_attach` recipe into your runlist to setup the Chef
  Client.
* Set server_url, private_ssh_key and validation_name to match the Chef Server
  configuration.

For more info see: [Release Notes](http://support.rightscale.com/18-Release_Notes/ServerTemplates_and_RightImages/v13.4#Chef_Client_\(v13.4\))

## DETAILS:

### General

The cookbook installs the Chef Client with needed configuration for CentOS and
Ubuntu.

### Attributes:

These are the settings used in recipes and templates. Default values are noted.
* `node[:chef][:client][:version]`-
  The package version. Default: "10.24.0-1"
* `node[:chef][:client][:config_dir]`-
  The Chef Client config directory. Default: "/etc/chef"
* `node[:chef][:client][:server_url]`-
  The url to connect to the remote Chef Server.
* `node[:chef][:client][:private_ssh_key]`-
  Private ssh key to register the Chef Client with the Chef Server.
* `node[:chef][:client][:validation_name]`-
  Validation name, along with the private ssh key, is used to determine whether
  the Chef Client may register with the Chef Server. The validation_name 
  located on the server and in the client configuration file must match.
* `node[:chef][:client][:node_name]`-
  The node's name to register on the Chef Server.
* `node[:chef][:client][:roles]`-
  Comma separated list of roles which will be applied to this instance. Roles
  should be defined on the Chef Server else recipe will fail.
* `node[:chef][:client][:environment]`-
  The Chef Server environment name. By default the Chef Client environment
  variable is set to "_default".
* `node[:chef][:client][:company]`-
  Company name to be set in the Client configuration file. This attribute is 
  applicable for Opscode Hosted Chef Server. The company name specified in both
  the Server and the Client configuration file must match.

### Templates:

* `chef_client_conf.erb`-
  The Chef Client configuration file. Used in `chef::do_attach` recipe.
* `private_ssh_key.erb`-
  The Chef Client private ssh key. Used in `chef::do_attach` recipe.
* `runlist.json.erb`-
  The Chef Client runlist.json file. Defined in setup_runlist definition and
  used in `chef::do_attach` and `chef::execute_runlist` recipes.

### Usage Example:

* `chef::do_attach`
  This recipe is used in boot phase to register the Chef Client on the Chef
  Server. It is also available in operational phase. Before using this recipe
  in operational phase user need to execute `chef::detach` recipe to remove
  all the configuration files from the client. To use a different Chef Server,
  user should change the server_url input. To reconnect to the same Chef Server
  other than RightScale Chef Server, user need to either change the node name
  input or remove the node and client registration entries from the server.

* `chef::execute_runlist`
  This recipe is used in operational phase only. It re-runs runlist received
  from the Chef Server. To update the roles user can provide new roles as input
  and run the recipe. Roles to be used should be available on the Chef Server.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
