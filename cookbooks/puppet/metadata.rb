maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures the Puppet Client and Server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.4.0"

depends "rightscale"

recipe "puppet::install_client",
  "Installs and configures the Puppet Client"
recipe "puppet::do_start",
  "Starts Puppet service"
recipe "puppet::do_stop",
  "Stops Puppet service"
recipe "puppet::do_restart",
  "Restarts Puppet service"
recipe "puppet::reload_agent",
  "Reloads the Puppet agent configuration"
recipe "puppet::setup_monitoring",
  "Configures the collectd monitoring for the Puppet Client"

attribute "puppet/client/version",
  :display_name => "Puppet Client Version",
  :description =>
    "Specify the Puppet Client version to match the requirements of your" +
    " Puppet Server. Provide the version in version-release format." +
    " Example: 2.7.13-1",
  :required => "optional",
  :default => "2.7.13-1",
  :recipes => ["puppet::install_client"]

attribute "puppet/client/node_name",
  :display_name => "Client Node Name",
  :description =>
    "Name which will be used to authenticate client on the remote Puppet" +
    " Server. If nothing is specified -instance fqdn will be used." +
    " Example: client_101.example.com",
  :required => "optional",
  :recipes => ["puppet::install_client"]

attribute "puppet/client/puppet_server_address",
  :display_name => "Puppet Server Url",
  :description =>
    "Enter the address to connect to the remote Puppet Server." +
    " Example: p_master.example.com",
  :required => "required",
  :recipes => ["puppet::install_client"]

attribute "puppet/client/puppet_server_port",
  :display_name => "Puppet Server Port",
  :description =>
    "Enter the port to connect to the remote Puppet Server." +
    " Example: 8140 ",
  :required => "optional",
  :default => "8140",
  :recipes => ["puppet::install_client"]

attribute "puppet/client/environment",
  :display_name => "Puppet Client Environment",
  :description =>
    "Specify the environment type for the Puppet Client configs." +
    " Example: development",
  :required => "optional",
  :recipes => ["puppet::install_client"]
