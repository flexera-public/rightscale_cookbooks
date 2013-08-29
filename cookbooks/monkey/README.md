# Monkey Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

This cookbook provides recipes to setup a VirtualMonkey test environment for
testing RightScale ServerTemplates.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale managed RightImage.

## COOKBOOK DEPENDENCIES:

Please see the `metadata.rb` for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

To setup the VirtualMonkey test environment, include the recipes in the
following order.

1. `monkey::setup_git`
2. `monkey::setup_ruby`
3. `monkey::setup_rest_connection`
4. `monkey::setup_virtualmonkey`
5. `monkey::setup_test_config`
6. `monkey::update_fog_credentials`

## DETAILS:

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internel" cookbook attributes are described here. Descriptions of
attributes which have inputs can be found in the metadata.rb file.

#### General attributes

* `node[:monkey][:rest][:gem_packages]` - List of Rubygems required by the
  rest_connection library along with the version information.
* `node[:monkey][:rest][packages]` - List of packages required for the
  rest_connection library.
* `node[:monkey][:virtualmonkey][:packages]` - List of packages required for
  the virtualmonkey library.

### Recipes:

1. `monkey::setup_git` - This recipe sets up the git credentials and
   configurations to checkout source code from git.
2. `monkey::setup_ruby` - The VirtualMonkey doesn't support Ruby 1.9.x yet. So
   this recipe will remove Ruby 1.9.x and install Ruby 1.8.7.
3. `monkey::setup_rest_connection` - This recipe will setup the rest_connection
   libraries which is used for communicating with RightScale API.
4. `monkey::setup_virtualmonkey` - This recipe will setup the virtualmonkey
   test framework.
5. `monkey::setup_rocketmonkey` - This recipe will setup rocketmonkey and also
   install the jenkins server.
6. `monkey::setup_test_config` - This recipe will setup test specific
   gems/packages.
7. `monkey::update_fog_credentials` - This recipe will create/update the fog
   credentials file with the inputs provided.

### Templates:

* `rest_api_config.yaml.erb` - Configuration for the rest_connection library.
* `sshconfig.erb` - Configuration for SSH connections.
* `gitconfig.erb` - Configuration for using Git.
* `fog.erb` - Cloud credentials to be used with the Fog library.
* `rocketmonkey_config.yaml.erb` - The RocketMonkey configuration file.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.
