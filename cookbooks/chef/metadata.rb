maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures the Chef Client and Server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"

recipe "chef::install_client",
  "Installs and configures the Chef Client"
recipe "chef::do_client_converge",
  "Allows manual update/re-run of runlist on the Chef Client"

attribute "chef/client/version",
  :display_name => "Chef Client Version",
  :description =>
    "Specify the Chef Client version to match requirements of your Chef" +
    " Server. Example: 10.24.0-1",
  :required => "optional",
  :default => "10.24.0-1",
  :recipes => ["chef::install_client"]

attribute "chef/client/server_url",
  :display_name => "Chef Server URL",
  :description =>
    "Enter the URL to connect to the remote Chef Server. To connect to the" +
    " Opscode Hosted Chef use the following syntax" +
    " https://api.opscode.com/organizations/ORGNAME." +
    " Example: http://example.com:4000/chef",
  :required => "required",
  :recipes => ["chef::install_client"]

attribute "chef/client/validator_pem",
  :display_name => "Private Key to Register the Chef Client with the Chef" +
    " Server",
  :description =>
    "Private SSH key which will be used to authenticate the Chef Client on" +
    " the remote Chef Server.",
  :required => "required",
  :recipes => ["chef::install_client"]

attribute "chef/client/validation_name",
  :display_name => "Chef Client Validation Name",
  :description =>
    "Validation name, along with the private SSH key, is used to determine" +
    " whether the Chef Client may register with the Chef Server. The" +
    " validation_name located on the Server and in the Client configuration" +
    " file must match. Example: ORG-validator",
  :required => "required",
  :recipes => ["chef::install_client"]

attribute "chef/client/node_name",
  :display_name => "Chef Client Node Name",
  :description =>
    "Name which will be used to authenticate the Chef Client on the remote" +
    " Chef Server. If nothing is specified, the instance FQDN will be used." +
    " Example: chef-client-host1",
  :required => "optional",
  :recipes => ["chef::install_client"]

attribute "chef/client/environment",
  :display_name => "Chef Client Environment",
  :description =>
    "Specify the environment type for the Chef Client configuration file." +
    " Example: development",
  :required => "optional",
  :default => "_default",
  :recipes => ["chef::install_client"]

attribute "chef/client/company",
  :display_name => "Chef Company Name",
  :description =>
    "Company name to be set in the Client configuration file. This attribute" +
    " is applicable for Opscode Hosted Chef Server. The company name" +
    " specified in both the Server and the Client configuration file must" +
    " match. Example: MyCompany",
  :required => "optional",
  :recipes => ["chef::install_client"]

attribute "chef/client/roles",
  :display_name => "Set of Client Roles",
  :description =>
    "Comma-separated list of roles which will be applied to this instance." +
    " The Chef Client will execute the roles in the order specified here." +
    " Example: webserver, monitoring",
  :required => "optional",
  :recipes => ["chef::install_client", "chef::do_client_converge"]

attribute "chef/client/runlist_override",
  :display_name => "JSON String used to override the first run of chef-client.",
  :description =>
    "A custom JSON string to override the first run of chef-client." +
    " Example: recipe[ntp::default]",
  :required => "optional",
  :recipes => ["chef::install_client"]

attribute "chef/client/log_level",
  :display_name => "Logging Level",
  :description =>
    "The level of logging that will be stored in the log file. Example: debug",
  :required => "optional",
  :default => "info",
  :recipes => ["chef::install_client"]

attribute "chef/client/log_location",
  :display_name => "Log File Location",
  :description =>
    "The location of the log file. Example: /var/log/chef-client.log",
  :required => "optional",
  :default => "/var/log/chef-client.log",
  :recipes => ["chef::install_client"]

