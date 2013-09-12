# RightScale Rsyslog Cookbook

## DESCRIPTION:

* This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).
* Cookbook provides rsyslog implementation of the logging LWRP.
* Configures rsyslog to log to a remote server or use default local file
  logging.

## REQUIREMENTS:

* Requires ["logging" Lightweight resource cookbook][logging]
* Requires a VM launched from a RightScale managed RightImage

[logging]: https://github.com/rightscale/rightscale_cookbooks/tree/master/cookbooks/logging

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

* Only supports configuration for remote server.
* Does not replace or upgrade installed rsyslog package.

## SETUP/USAGE:

* There are no standalone recipes in the current implementation of this
  cookbook.
  The 'rsyslog' provider is set up by the logging:default recipe based on the
  logging package installed.

## DETAILS:

## General:

The `logging_rsyslog` cookbook does the minimal configuration for a remote
logging setup. Additional features are TBD.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
