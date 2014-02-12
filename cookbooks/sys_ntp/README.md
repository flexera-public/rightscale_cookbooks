# RightScale System NTP Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

This cookbook provides a recipe for setting up time synchronization using NTP.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

Place the `sys_ntp::default` recipe into the boot recipes.

## DETAILS:

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs you can find in the `metadata.rb` cookbook
file.

* `node[:sys_ntp][:service]` - Name of the service that NTP runs as.
  Default is `ntp` on Ubuntu and `ntpd` on CentOS and RedHat.

### Templates:

**ntp.conf.erb**

Configuration for the NTP daemon used in the `sys_ntp::default` recipe.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
