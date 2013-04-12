# Monkey Cookbook

## DESCRIPTION:

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
5. `monkey::setup_rocketmonkey`
6. `monkey::update_fog_credentials`
7. `monkey::test_virtualmonkey_api_connection`

## DETAILS:

### Recipes:

1. `monkey::setup_git` - This recipe sets up the git credentials and
   configurations to checkout source code from git.
2. `monkey::setup_ruby` - The VirtualMonkey doesn't support Ruby 1.9.x yet. So
   this recipe will remove Ruby 1.9.x and install Ruby 1.8.7.
3. `monkey::setup_rest_connection` - This recipe will setup the rest_connection
   libraries which is used for communicating with RightScale API.
4. `monkey::setup_virtualmonkey` - This recipe will setup the virtualmonkey
   test framework.
5. `monkey::setup_rocketmonkey` - This recipe will setup rocketmonkey.
6. `monkey::update_fog_credentials` - This recipe will create/update the fog
   credentials file with the inputs provided.
7. `monkey::test_virtualmonkey_api_connection` - This recipe will perform some
   smoke tests to verify the API connection to RightScale.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.
