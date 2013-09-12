# RightScale Ruby Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

This cookbook provides recipes for setting up specific versions of Ruby.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

Place the `ruby::install_1_8` recipe into the boot recipes to install ruby 1.8
with rubygems.

Place the `ruby::install_1_9` recipe into the boot recipes to install ruby 1.9
with rubygems.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.
