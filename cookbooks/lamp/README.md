# RightScale LAMP Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

Basic all-in-one LAMP (Linux, Apache, MySQL, PHP) cookbook designed to work in a
hybrid cloud setting.

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

Place the `lamp::default` recipe into your boot recipes after
`db_mysql::setup_server_<version>`, `db::install_server`,
`app_php::setup_server_5_3`, and `app::install_server` recipes.

## DETAILS:

The `lamp::default` sets up attributes for the `app` and `db_mysql` cookbooks:
it sets the app server to listen on port 80, and it sets the database server to
listen only on `localhost`.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
