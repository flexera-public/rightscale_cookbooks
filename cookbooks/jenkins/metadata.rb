maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures a memcached server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04" 


depends "rightscale"
depends "sys_firewall"
depends "logrotate"


recipe "memcached::default", "Default recipe for memcached setup."


attribute "memcached/tcp_port",
  :display_name => "Memcached TCP Port",
  :description => "The TCP port to use for connections. Default : 11211",
  :required => "recommended",
  :default => "11211",
  :recipes => ["memcached::install_server", "memcached::default"]

