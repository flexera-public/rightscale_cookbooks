maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures the Chef client"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.4.0"

depends "rightscale"

recipe "chef::install_client",
  "Installs and configures the Chef client."
recipe "chef::do_attach",
  "Attach the Chef client and deploy configuration."
recipe "chef::do_detach",
  "Detach the Chef client and remove configuration."
recipe "chef::execute_runlist",
  "Execute the Chef client."

attribute "chef/client/version",
  :display_name => "Chef client version",
  :description =>
  "Specify the Chef client version to match requirements of your Chef server." +
  " Example: 10.24.0-1",
  :required => "optional",
  :default => "10.24.0-1",
  :recipes => ["chef::install_client"]

attribute "chef/client/server_url",
  :display_name => "Chef server url",
  :description =>
  "Enter the url to connect to the remote Chef server. To connect the Opscode" +
  " Hosted Chef use the following syntax" +
  " https://api.opscode.com/organizations/ORGNAME." +
  " Example: http://example.com:4000/chef",
  :required => "required",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/private_ssh_key",
  :display_name => "Chef client private ssh key",
  :description =>
    "SSH private key which will be used to authenticate the client on the" +
    " remote Chef server.",
  :required => "required",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/validation_name",
  :display_name => "Chef client validation name",
  :description =>
    "validation name, along with the private ssh key, is used to determine" +
    " whether the Chef client may register with the Chef server. The" +
    " validation_name located on the server and in the client configuration" +
    " file must match. Example: ORG-validator",
  :required => "required",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/node_name",
  :display_name => "Chef client node name",
  :description =>
    "Name which will be used to authenticate the client on the remote Chef" +
    " server. If nothing specified, the instance fqdn will be used. Example:" +
    " client_101.example.com",
  :required => "optional",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/environment",
  :display_name => "Chef client environment",
  :description =>
    "Specify the environment type for the Chef client configs." +
    " Example: development",
  :required => "optional",
  :default => "_default",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/company",
  :display_name => "Chef company name",
  :description =>
    "The name of the company which is defined on the Chef server. If not" +
    " specified, this attribute will set to blank. Example: MyCompany",
  :required => "optional",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/roles",
  :display_name => "Set of client roles",
  :description =>
    "Comma separated list of roles, which will be applied to this instance." +
    " Example: webserver, monitoring",
  :required => "optional",
  :recipes => [
    "chef::install_client",
    "chef::do_attach",
    "chef::execute_runlist"
  ]
