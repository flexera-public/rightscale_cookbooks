maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Virtual Monkey"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04" 


depends "rightscale"
depends "sys_firewall"
depends "logrotate"


recipe "monkey::default", "Default recipe for monkey setup."
recipe "monkey::setup_git", "Setting up Git for monkey."
recipe "monkey::setup_rest_connection", "Setting up rest_connection for monkey."
recipe "monkey::setup_virtualmonkey", "Setting up virtualmonkey."
recipe "monkey::test_virtualmonkey_api_connection", "Testing API connectivity for virtualmonkey."
recipe "monkey::setup_rightcloud_private_api", "Setting up rightcloud_private_api gem."

#attribute "memcached/tcp_port",
#  :display_name => "Memcached TCP Port",
#  :description => "The TCP port to use for connections. Default : 11211",
#  :required => "recommended",
#  :default => "11211",
#  :recipes => ["memcached::install_server", "memcached::default"]
#
