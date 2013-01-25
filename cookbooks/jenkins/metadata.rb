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


recipe "jenkins::default", "Default recipe for jenkins setup."
recipe "jenkins::install_jenkins", "Installing jenkins."

attribute "jenkins/server/user_name",
  :display_name => "Jenkins User Name",
  :description => "***",
  :required => "required",
  :recipes => [ "jenkins::install_jenkins" ]

attribute "jenkins/server/user_email",
  :display_name => "Jenkins User Email",
  :description => "***",
  :required => "required",
  :recipes => [ "jenkins::install_jenkins" ]

attribute "jenkins/server/user_full_name",
  :display_name => "Jenkins User full Name",
  :description => "***",
  :required => "required",
  :recipes => [ "jenkins::install_jenkins" ]

attribute "jenkins/server/password",
  :display_name => "Jenkins Password",
  :description => "***",
  :required => "required",
  :recipes => [ "jenkins::install_jenkins" ]

attribute "jenkins/server/plugins",
  :display_name => "Jenkins Plugins",
  :description => "***",
  :required => "required",
  :recipes => [ "jenkins::install_plugins" ]

#attribute "memcached/tcp_port",
#  :display_name => "Memcached TCP Port",
#  :description => "The TCP port to use for connections. Default : 11211",
#  :required => "recommended",
#  :default => "11211",
#  :recipes => ["memcached::install_server", "memcached::default"]

