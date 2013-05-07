maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures a memcached server"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04" 


depends "rightscale"
depends "sys_firewall"
depends "logrotate"


recipe "memcached::default",
  "Sets up mecached.."

recipe "memcached::install_server",
  "Installs and configures memcached, opens port in firewall," +
  " and configures collectd and logrotate."

recipe "memcached::do_start",
  "Starts memcached service."

recipe "memcached::do_restart",
  "Restarts memcached service."

recipe "memcached::do_stop",
  "Stops memcached service."


attribute "memcached/tcp_port",
  :display_name => "Memcached TCP Port",
  :description =>
    "The TCP port to use for connections. Example: 11211",
  :required => "recommended",
  :default => "11211",
  :recipes => ["memcached::install_server", "memcached::default"]

attribute "memcached/udp_port",
  :display_name => "Memcached UDP Port",
  :description =>
    "The UDP port to use for connections. Example: 11211",
  :required => "recommended",
  :default => "11211",
  :recipes => ["memcached::install_server", "memcached::default"]

attribute "memcached/user",
  :display_name => "Memcached user",
  :description =>
    "The user for executing memcached. Example: nobody",
  :required => "recommended",
  :default => "nobody",
  :recipes => ["memcached::install_server"]

attribute "memcached/connection_limit",
  :display_name => "Memcached connection limit",
  :description =>
    "Option to either reduce the number of connections" +
    " (to prevent overloading memcached service) or to increase the number" +
    " making more effective use of the server running memcached. Example: 1024",
  :required => "recommended",
  :default => "1024",
  :recipes => ["memcached::install_server"]

attribute "memcached/memtotal_percent",
  :display_name => "Memcached Cache size percentage",
  :description =>
    "Set the amount of memory allocated to memcached" +
    " for object storage in percentage from total system memory. Example: 80",
  :required => "recommended",
  :choice => ["10", "20", "30", "40", "50", "60", "70", "80", "90"],
  :default => "90",
  :recipes => ["memcached::install_server"]

attribute "memcached/threads",
  :display_name => "Memcached used threads",
  :description =>
    "The number of threads to use when processing incoming requests. Example: 4",
  :required => "recommended",
  :default => "1",
  :recipes => ["memcached::install_server"]

attribute "memcached/interface",
  :display_name => "Memcached listening interface",
  :description =>
    "Interface used for memcached connections. Example: any",
  :required => "recommended",
  :choice => ["localhost", "private", "any"],
  :default => "any",
  :recipes => ["memcached::install_server"]

attribute "memcached/log_level",
  :display_name => "Memcached logging output level",
  :description =>
    "Without the verbose options, memcached normally produces no output" +
    " during normal operating. Example: off",
  :required => "optional",
  :choice => ["off", "verbose", "debug", "extremely verbose"],
  :default => "off",
  :recipes => ["memcached::install_server"]

attribute "memcached/cluster_id",
  :display_name => "Memcached cluster_id",
  :description =>
    "Used to associate server with a memcached cluster. Example: cache_cluster",
  :required => "optional",
  :default => "cache_cluster",
  :recipes => ["memcached::install_server", "memcached::default"]
