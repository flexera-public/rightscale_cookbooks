# Jenkins Cookbook

## DESCRIPTION:

This cookbook provides recipes to setup and Jenkins servers and slaves.

## REQUIREMENTS:

Requires a virtual machine from a RightScale managed RightImage.

## COOKBOOK DEPENDENCIES:

Please see the `metadata.rb` for the latest dependencies.

## KNOWN LIMITATIONS:

Jenkins currently runs as root user. This is required for using the
VirtualMonkey test framework. Once the test framework is fixed to run as a
regular user, this limitation can be removed.

## SETUP/USAGE:

* To setup a Jenkins server include `jenkins::install_server` to your runlist.
  This recipe will Jenkins server and configure the server.
* To add a server as a slave to existing Jenkins master server, run the
  `jenkins::do_attach_request` recipe. This recipe will attach the server as a
  slave to the Jenkins master server found in the current deployment.

## DETAILS:

### Recipes:

#### `jenkins::install_server`

This recipe installs the Jenkins server from the mirrors provided by
jenkins-ci.org. This recipe also allows a particular version of Jenkins
installed based on the `jenkins/server/version` input (Please refer to the
`metadata.rb` for more information about this input).

The master node will add tags to announce itself as a master with information
about its listen IP address and Port number. Jenkins slaves will use this
information for communication.

#### `jenkins::do_attach_request`

This recipe attaches a server as a slave to the Jenkins master server found in
the current deployment. It uses the Jenkins API to request the master server to
attach itself as a slave. The slave nodes will add information as tags about its
IP address, mode, and name.

##### Slave mode:

The mode for a slave could be either 'normal' or 'exclusive'. The slaves in
'normal' can be used to run any jobs. The slaves in 'exclusive' mode can only
run jobs that are tied/restricted to themselves. The default mode for a slave
will be 'normal' unless otherwise overridden.

##### Slave name:

Jenkins master uses the name to identify slaves and restrict jobs to a
particular slave. This name will be chosen to be the RightScale Instance UUID
if it is not specified in the inputs.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.  All access and use subject to
the RightScale Terms of Service available at http://www.rightscale.com/terms.php
and, if applicable, other agreements such as a RightScale Master Subscription
Agreement.
