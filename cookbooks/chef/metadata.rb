maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Common utilities for RightScale managed application servers"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.4.0"

depends "rightscale"

recipe "chef::install_client",
  "Installs and configures Chef client."
recipe "chef::do_attach",
  "Attach Chef client and deploy configuration."
recipe "chef::do_detach",
  "Detach Chef client and remove configuration."
recipe "chef::execute_runlist",
  "Execute Chef client."

attribute "chef/client/version",
  :display_name => "Chef client version",
  :description =>
  "Specify the Chef client version to match requirements of your Chef server." +
  " Example: 10.18.2-2",
  :required => "optional",
  :default => "10.18.2-2",
  :recipes => ["chef::install_client"]

attribute "chef/client/server_url",
  :display_name => "The URL for the Chef server",
  :description =>
  "Enter the url to connect to remote Chef server. To connect Opscode Hosted" +
  " Chef use the following syntax https://api.opscode.com/organizations/ORGNAME" +
  " . Example: http://example.com:4000/chef",
  :required => "required",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/private_ssh_key",
  :display_name => "Chef client private ssh key",
  :description =>
  "Private ssh key which will be used to authenticate the client on the remote" +
  " Chef server.",
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
  :display_name => "The node's name",
  :description =>
  "The node's name to register on Chef server.",
  :required => "optional",
  :recipes => ["chef::install_client", "chef::do_attach"]

attribute "chef/client/environment",
  :display_name => "Chef client environment",
  :description =>
  "Specify environment type for the Chef client configs. Example: development",
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
