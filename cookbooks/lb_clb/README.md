# RightScale Rackspace Cloud Load Balancers (CLB) Cookbook

## DESCRIPTION:

This cookbook is available at [https://github.com/rightscale/rightscale_cookbooks](https://github.com/rightscale/rightscale_cookbooks).

RightScale load balancer cookbook for Rackspace Cloud Load Balancing (CLB).

This cookbook provides recipes for attaching and detaching application servers
to and from an existing Rackspace Cloud Load Balancer (CLB).

## DETAILS:

The recipes in this cookbook are designed to enable an application server to
attach itself to or detach itself from an existing Rackspace Cloud Load Balancer
(CLB). The name of the existing CLB is provided as an input. The application
server is then associated with the CLB on Rackspace. Administrators create and
edit CLBs using the Rackspace web interface.

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale-managed RightImage

* Requires an existing Rackspace Cloud Load Balancer

## SETUP/USAGE:

### Application Server Attach

#### do_attach_request

This recipe is used by application servers to request that a Rackspace CLB
attach the application server to its configuration. The recipe sends
the server's internal IP address as a parameter to the CLB.

### Application Server Detach

#### do_detach_request

This recipe is used by application servers to request that a Rackspace CLB
detach the application server from its configuration. The recipe sends the
server's internal IP address as a parameter to the CLB. Note: If this is the
only application server in the CLB configuration, it will not detach. This is a
known limitation of Rackspace CLB, and is disallowed in the Rackspace web
interface as well.

## KNOWN LIMITATIONS:

* If an application server is the only attached item for a CLB, it cannot be
  detached. This appears to be by design, as attempting to do this manually from
  the Rackspace web interface also fails.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
