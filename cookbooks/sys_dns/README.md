# RightScale System DNS cookbook

## DESCRIPTION:

This cookbook provides a set of dynamic DNS recipes used by RightScale
ServerTemplates including the Database Manager ServerTemplates.

## REQUIREMENTS:

* An account with the desired DNS service provider.
* DNS A record’s created external to this cookbook.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

Currently only the first private IP address can be set.

## SETUP/USAGE:

* Place `sys_dns::default` recipe into your runlist to set up the dynamic DNS
  provider resource. This will install the support tools and chef providers for
  the dynamic DNS provider selected by the "DNS Service Provider" input. When
  using a RightScale ServerTemplate, this will automatically add the common DNS
  service provider attributes to your ServerTemplate inputs.
* Place `sys_dns::do_set_private` recipe in your runlist to set the DNS record
  identified by the "DNS Record ID" input to the first private IP address of
  the instance if the private IP is desired.
* Place `sys_dns::do_set_public` recipe in your runlist to set the DNS record
  identified by the "DNS Record ID" input to the first public IP address of the
  instance if the public IP is desired. This recipe will fail if no valid
  public IP is found for the instance.

## DETAILS:

### General

Cookbook currently supports Cloud DNS, DNSMadeEasy, DynDNS, and Amazon Route53
DNS service providers.
A new chef provider can be created to add support for additional dynamic DNS
service providers.

For additional information: {Deployment Prerequisites}[http://support.rightscale.com/03-Tutorials/Deployment_Prerequisites_(Chef)]

### Attributes:

These are settings used in recipes and templates. Default values are noted.

* `node[sys_dns][choice]` -
  The name of your DNS provider.
* `node[sys_dns][id]` -
  The unique identifier that is associated with the DNS A record of the server.
* `node[sys_dns][user]` -
  The username that is used to access and modify your DNS A records.
* `node[sys_dns][password]` -
  The password that is used to access and modify your DNS A records.
* `node[sys_dns][region]` -
  Region where the A records should be modified. This input only applies to
  Cloud DNS.

### Libraries-helpers:

Use this section only if your cookbook contains any libraries.
Give complete description of library purpose and functionality.
Provide examples of how it is used in recipes.

#### Example:

**RightScale::DnsTools::CloudDNS.new(Chef::Log).action_set(id, user, password,
address, region)**
**RightScale::DnsTools::DME.new(Chef::Log).action_set(id, user, password,
address)**
**RightScale::DnsTools::DynDNS.new(Chef::Log).action_set(id, user, password,
address)**
**RightScale::DnsTools::AWS.new(Chef::Log).action_set(id, user, password,
address)**

Return the result of A record update process.

Parameters:

* `id::`
  The unique identifier that is associated with the DNS A record of the server.
* `user::`
  The username that is used to access and modify the DNS A records.
* `password::`
  The password that is used to access and modify the DNS A records.
* `address::`
  Private IP address of the instance running the recipe.
* `region::`
  Region where the A records should be modified. This input only applies to
  Cloud DNS.

Returns:

`Chef::Log::` A record successful update message.

Raise:

`Chef::Log::` Error message that may have occurred during the update process.

### LWRPs:

The 'set' interface is defined by a Lightweight Resource, which can be found in
the resources/default.rb file.

Used to pass data to the helper file and call the corresponding DNS provider.

For more information, please see [Lightweight Resources and Providers][Guide].

[Guide]: http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/08-Chef_Development/Lightweight_Resources_and_Providers_(LWRP)

#### Example:

Common attributes

* `:id` -
  The unique identifier that is associated with the DNS A record of the server.
* `:user` -
  The username that is used to access and modify your DNS A records.
* `:password` -
  The password that is used to access and modify your DNS A records.
* `:address` -
  Private IP address of the instance running the recipe.
* `:region` -
  Region where the A records should be modified. This input only applies to
  Cloud DNS.
* `:choice` -
  One of the supported DNS providers:"DNSMadeEasy"/"DynDNS"/"Route53"/"CloudDNS"

#### Example:

**Update Action**

To update A record with a server's private IP address:

    sys_dns "default" do
      id node[:db][:dns][:slave][:id]
      address private_ip
      action :set
    end

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
