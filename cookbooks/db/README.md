# RightScale Database Cookbook

## DESCRIPTION:

This cookbook provides a set of database recipes used by the RightScale
Database Manager ServerTemplates.

This cookbook does not contain a specific database implementation, rather
it provides an interface for general database actions and parameters.

## REQUIREMENTS:

* Must be used with a 'db' provider in the cookbook path.
* Depends on a `block_device` resource for backup and restore recipes.
* Requires a virtual machine launched from a RightScale-managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

* Only one db provider should be present in your cookbook path.

## SETUP:

* To setup only the database client, place `db::default` recipe into
  your runlist. This will pull in generic client inputs, provide provider
  selection input and install client. Set db/provider_type input in
  RightScale ServerTemplate to set provider and version for 'db' resource.
  Packages specific to the database for application servers will be installed by
  the `install_client_driver` action of the db_<provider> based on the type
  of driver. The driver type should be set by the application servers and
  passed to the db_<provider> cookbook. This action also sets the
  `node[:db][:client][:driver]` attribute which is used to perform
  database specific actions.
* To setup a database client and server, place the following recipes
  in order to your runlist:

    db_<provider>::setup_server_<version>
      loads the database provider, tuning parameters, as well as other
      provider-specific attributes into the node as inputs.

    db::install_server
      sets up generic server and client inputs. This will also include
      db::default recipe which installs the client.

  For example: To set up and install MySQL 5.5 client and server

    db_mysql::setup_server_5_5
    db::install_server

## USAGE:

### Initialize a master database:

1. Once your server is operational, run the:

    "db::do_init_and_become_master"

   recipe, which initializes your database onto a block device
   that supports backup and restore operations.
2. Initialize your database from previous dump file or other source.
3. Register your database with a DNS provider that supports dynamic DNS using:

    "sys_dns::do_set_private"

   to allow your application servers to start making connections.
4. Backup your database using:

    "db:do_backup"

   so that you can restore the master database in the event 
   of a failure or planned termination.

### Restore a master database:

1. Once your server is operational, run the:

    "db::do_restore"

   recipe, which restores your database from a backup previously saved to
   persistent cloud storage.
2. Register your database with a DNS provider that supports dynamic DNS using:

    "sys_dns::do_set_private"

   to allow your application servers to start making connections.

### Setup database client:

1. Put "db::default" into database client ServerTemplate runlist.
   Use db/provider_type input to select from existing clients or override this
   input to add custom type of database client
   db/provider_type Input selects your database provider cookbook
   (e.g. db_mysql, db_postgres, db_oracle, etc.) and what database version the
   client will connect to. (e.g. 5.1, 5.5, 9.1). This affects what connector
   package to install. Syntax for this input is
   <cookbook>_<version> (i.e. db_mydatabase_1.0)
2. Fill `db/application/password` , `db/application/user` and
   `db/dns/master/fqdn` inputs which are necessary to connect client to
   Database Manager.

## DETAILS:

### General

The 'db' interface is defined by a Lightweight Resource, which can be found in
the 'resources/default.rb' file.

This cookbook is intended to be used in conjunction with cookbooks that contain
Lightweight Providers which implement the 'db' interface. See RightScale's
'db_mysql' cookbook for an example.

For more information about Lightweight Resources and Providers (LWRPs), please
see: [Lightweight Resources and Providers][LWRP]

[LWRP]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/04-Developer/06-Development_Resources/Lightweight_Resources_and_Providers_(LWRP)

### Backup/Restore

This cookbook depends on the block_device LWRP for backup and restore actions.
See `db::do_backup` and `db::do_restore` recipes for examples. The
'block_device' cookbook provides primary and secondary persistence solutions for
multiple clouds.

However, using LWRPs one can provide their own block device implementation
instead.

Please see the 'block_device' cookbook for the list of available actions,
attributes and usage.

### Providers:

When writing your own database Lightweight Provider:

* The database provider to use is defined by the `node[:db][:provider]`
  attribute. You will need to override this attribute by adding the following
  code in the attributes file of your provider cookbook.

    set[:db][:provider] = "db_myprovider"

* Any database-specific attributes that you wish to make into user-configurable
  inputs should be added to the cookbook metadata with the default recipe included in
  the attribute's 'recipes' array. For more about Chef metadata, please see:
  [Chef Metadata][Guide]
* Your provider cookbook metadata should depend on this cookbook by adding a
  'depends' line to its metadata. For example:

    depends "db"

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/02-End_User/04-RightScale_Support_of_Chef/Chef_Metadata

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
