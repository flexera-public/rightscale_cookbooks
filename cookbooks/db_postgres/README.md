# RightScale PostgreSQL Database Cookbook

## DESCRIPTION:

Provides the PostgreSQL implementation of the 'db' resource to install and
manage PostgreSQL database stand-alone servers and clients.

## DETAILS

The 'db' implementation is defined by a Lightweight Provider, which can be
found in the providers/default.rb file.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage
* Needs RightScale ServerTemplate tools gem installed on system.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP:

* To setup only the database client, place `db::default` recipe into
  your runlist. This will pull in generic client inputs, provide
  provider selection input and install client. Set db/provider_type input in
  RightScale ServerTemplate to set provider and version for 'db' resource.
* To setup a PostgreSQL database client and server, place the following recipes
  in order to your runlist:

    db_postgres::setup_server_<version>
      loads the PostgreSQL provider, tuning parameters, as well as other
      PostgreSQL-specific attributes into the node as inputs.
    db::install_server
      sets up generic server and client inputs. This will also include
      db::default recipe which installs the client.

  For example: To set up and install PostgreSQL 9.1 client and server

    db_postgres::setup_server_9_1
    db::install_server

## USAGE:

### Basic usage

Once setup, use the recipes in the 'db' cookbook to install and manage your
PostgreSQL database servers and clients. See the `db/README.md` for usage
details.

### PostgreSQL Tuning and postgresql.conf and pg_hba.conf

Custom tuning parameters can be applied by overriding the
`postgresql.conf.erb` template or by setting the values in the attributes
file. For more information and an example override repository, please see:
[Override Chef Cookbooks][CCDG].

[CCDG]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/08-Chef_Development/Override_Chef_Cookbooks

The tuning parameters are adjusted based on the database server usage. Shared
servers are allocated %50 of the resources of a dedicated server.

The current implementation sets the following tuning parameters:

* max_connections: Static setting with 400 for a dedicated server
  and 200 for a shared server
* shared_buffers: Dynamically set to %25 of available memory.

## DETAILS:

The 'db' implementation is defined by a Lightweight Provider, which can be
found in the `providers/default.rb` file.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
