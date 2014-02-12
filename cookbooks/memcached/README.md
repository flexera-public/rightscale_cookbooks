# RightScale Memcached Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

This cookbook provides recipes for setting up and running a Memcached server.

## REQUIREMENTS:

* Requires a VM launched from a RightScale managed RightImage

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

* If you need memcached to listen on public interface must set to listen on any.

## SETUP/USAGE:

* Choose image and cloud.
* Fill required input fields.
* When using a RightScale ServerTemplate, place `memcached::install_server`
  recipe into your runlist to setup the memcached server and add the server
  tags.

## DETAILS:

### General

The cookbook installs memcached with needed configuration for CentOS, Redhat and
Ubuntu.
Opens listening port in systems' firewall, setups server tags, monitoring and
log rotation.

### Attributes:

These are the settings used in recipes and templates. Default values are noted.
* `node[:memcached][:tcp_port]` -
  The TCP port to use for connections. Default: 11211
* `node[:memcached][:udp_port]` -
  The UDP port to use for connections. Default: 11211
* `node[:memcached][:user]` -
  The user for executing memcached. Default: nobody
* `node[:memcached][:connection_limit]` -
  Option to either reduce the number of connections (to prevent overloading
  memcached service) or to increase the number making more effective use of the
  server running memcached. Default: 1024
* `node[:memcached][:memtotal_percent]` -
  The amount of memory allocated to memcached for object storage in percentage
  from total system memory. Example: 80
* `node[:memcached][:threads]` -
  The number of threads to use when processing incoming requests. Example: 4
* `node[:memcached][:interface]` -
  Interface used for memcached connections. Default: any
* `node[:memcached][:log_level]` -
  Memcached logging output level
* `node[:memcached][:cluster_id]` -
  Cluster assosiation string.

### Templates:

* `memcached.conf.erb` -
  Memcached configuration file. Unique for CentOS and Ubuntu. Used is the
  `memcached::install_server` recipe.
* `memcached_collectd.conf.erb` - Memcached collectd plugin template. Used is
  the `memcached::install_server` recipe.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
