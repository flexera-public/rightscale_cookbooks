# RightScale AWS Elastic Load Balancer (ELB) Cookbook

## DESCRIPTION:

RightScale load balancer cookbook for AWS Elastic Load Balancer (ELB).

This cookbook provides recipes for attaching and detaching application servers
to and from an existing AWS Elastic Load Balancer (ELB).

## DETAILS:

The recipes in this cookbook are designed to enable an application server to
attach itself to or detach itself from an existing AWS Elastic Load Balancer
(ELB). The name of an existing ELB is provided as an input. The application
server is then associated with the ELB on AWS. Administrators create ELBs using
the RightScale Dashboard.

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale-managed RightImage

* Requires an existing AWS Elastic Load Balancer

## SETUP/USAGE:

### Application Server Attach

#### do_attach_request

This recipe is used by application servers to request that an AWS ELB attach the
application server to its configuration. The recipe sends the server's instance
ID as a parameter to the ELB.

### Application Server Detach

#### do_detach_request

This recipe is used by application servers to request that an AWS ELB detach the
application server from its configuration. The recipe sends the server's
instance ID as a parameter to the ELB.

## KNOWN LIMITATIONS:

There are no known limitations.

## LICENSE

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
