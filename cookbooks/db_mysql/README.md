# RightScale MySQL Database Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

Provides the MySQL implementation of the 'db' resource to install and manage
MySQL database stand-alone servers and clients.

## REQUIREMENTS:

* Requires a server launched from a RightScale managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP:

* To setup only the database client, place `db::default` recipe into
  your runlist. This will pull in generic client inputs, provide provider
  selection input and install client. Set db/provider_type input in
  RightScale ServerTemplate to set provider and version for 'db' resource.
* To setup a MySQL database client and server, place the following recipes
  in order to your runlist:

    db_mysql::setup_server_<version>
      loads the MySQL provider, tuning parameters, as well as other
      MySQL-specific attributes into the node as inputs.

    db::install_server
      sets up generic server and client inputs. This will also include
      db::default recipe which installs the client.

  For example: To set up and install MySQL 5.5 client and server

    db_mysql::setup_server_5_5
    db::install_server

## USAGE:

### Basic usage

Once setup, use the recipes in the 'db' cookbook to install and manage your
MySQL database servers and clients. See the `db/README.md` for usage details.

### MySQL Tuning and my.cnf

Custom tuning parameters can be applied by overriding the `my.cnf.erb`
template or by setting the values in the attributes file. For more information
and an example override repository, please see: [Override Chef Cookbooks][CCDG].

[CCDG]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/ServerTemplate_Development/08-Common_Development_Tasks/Override_Chef_Cookbooks

## DETAILS:

### General

The 'db' implementation is defined by a Lightweight Provider, which can be
found in the `providers/default.rb` file.

The ‘read_only’ flag in the MySQL configuration is set by the definition
`db_mysql_set_read_only`. This flag is set to ‘false’ by default
and changed to ‘true’ while initializing a slave server, and set back to
‘false’ when the slave is promoted to a master server.

### Attributes:

These are settings used in recipes and templates. Default values are noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs can be found in the metadata.rb cookbook file. For
generic db attributes, refer to the db cookbook readme.

##### General attributes

* `node[:db_mysql][:collectd_master_slave_mode]` -
  The mode for collectd in MySQL server.
* `node[:db_mysql][:port]` -
  The port on which MySQL server listens.
* `node[:db_mysql][:log_bin_enabled]` -
  Determines whether binary logging is enabled or disabled.
* `node[:db_mysql][:datadir]` -
  The data directory for MySQL server where the database contents are stored.
* `node[:db_mysql][:bind_address]` -
  The IP address that MySQL server uses to bind. It is set to "0.0.0.0" allowing
  mysql clients/GUI tools to connect from the outside.
* `node[:db_mysql][:dump][:storage_account_provider]` -
  The storage account provided MySQL dump backup.
* `node[:db_mysql][:dump][:storage_account_id]` -
  The storage account ID for MySQL dump backup.
* `node[:db_mysql][:dump][:storage_account_secret]` -
  The storage account secret for MySQL dump backup.
* `node[:db_mysql][:dump][:container]` -
  The container name to be used for dump backup.
* `node[:db_mysql][:dump][:prefix]` -
  The prefix to be used with container name.

##### System tuning parameters

* `node[:db_mysql][:file_ulimit]` -
  A tuning parameter to set maximum open files for mysql and root users.
* `node[:db_mysql][:backup][:slave][:max_allowed_lag]` -
  Maximum allowed lag time for MySQL slave backup.

##### Platform dependent

* `node[:db_mysql][:log]` - The log file location for MySQL server.
* `node[:db_mysql][:log_error]` - The error log file location for MySQL server.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
