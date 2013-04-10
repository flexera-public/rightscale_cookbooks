maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Jenkins"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"


depends "rightscale"
depends "sys_firewall"
depends "logrotate"


recipe "jenkins::default", "Default recipe for Jenkins setup."
recipe "jenkins::install_server", "Install Jenkins."
recipe "jenkins::install_plugins", "Install Jenkins plugins."
recipe "jenkins::do_attach_request", "Installing Jenkins."
recipe "jenkins::do_attach_slave_at_boot", "Installing Jenkins."

# Server/Master Attributes

attribute "jenkins/server/user_name",
  :display_name => "Jenkins User Name",
  :description => "Default user's sign in name.",
  :required => "required",
  :recipes => ["jenkins::install_server", "jenkins::do_attach_request"]

attribute "jenkins/server/user_email",
  :display_name => "Jenkins User Email",
  :description => "Default user's email.",
  :required => "required",
  :recipes => ["jenkins::install_server"]

attribute "jenkins/server/user_full_name",
  :display_name => "Jenkins User Full Name",
  :description => "Default user's full name.",
  :required => "required",
  :recipes => ["jenkins::install_server"]

attribute "jenkins/server/password",
  :display_name => "Jenkins Password",
  :description => "Default user's password.",
  :required => "required",
  :recipes => ["jenkins::install_server", "jenkins::do_attach_request"]

attribute "jenkins/server/version",
  :display_name => "Jenkins Version",
  :description => "Jenkins version to install. Leave it blank to get the" +
    " latest version. Example: 1.500",
  :required => "optional",
  :recipes => ["jenkins::install_server"]

attribute "jenkins/server/plugins",
  :display_name => "Jenkins Plugins",
  :description => "Jenkins plugins to install.",
  :required => "optional",
  :recipes => ["jenkins::install_server"]

# Slave Attributes

attribute "jenkins/slave/name",
  :display_name => "Jenkins Slave Name",
  :description => "Name of Jenkins slave. This name should be unique. The" +
    " RightScale instance uuid will be used as the name if this input is" +
    " left blank",
  :required => "optional",
  :recipes => ["jenkins::do_attach_request"]

attribute "jenkins/slave/mode",
  :display_name => "Jenkins Slave Mode",
  :description => "Mode of Jenkins slave. Choose 'normal' if this slave can" +
    " be used for running any jobs or choose 'exclusive' if this slave should" +
    " be used only for tied jobs.",
  :default => "normal",
  :choice => ["normal", "exclusive"],
  :recipes => ["jenkins::do_attach_request"]

attribute "jenkins/slave/executors",
  :display_name => "Jenkins Slave Executors",
  :description => "Number of Jenkins executors.",
  :required => "optional",
  :recipes => ["jenkins::do_attach_request"]


# Attributes shared between master and slave

attribute "jenkins/public_key",
  :display_name => "Jenkins Public Key",
  :description => "This public key will be used by Jenkins slave to allow" +
    " connections from the master/server",
  :required => "required",
  :recipes => ["jenkins::do_attach_request"]

attribute "jenkins/private_key",
  :display_name => "Jenkins Private Key",
  :description => "This key is used by Jenkins master/server to connect to" +
    " the slave using SSH.",
  :required => "required",
  :recipes => ["jenkins::install_server"]

attribute "jenkins/attach_slave_at_boot",
  :display_name => "Attach Jenkins Slave At Boot",
  :description => "Set this input to 'true' if this is a Jenkins slave and" +
    " should be connected as a slave to the Jenkins server/master at boot.",
  :default => "false",
  :choice => ["true", "false"],
  :recipes => ["jenkins::do_attach_slave_at_boot"]

