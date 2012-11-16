maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures lb_haproxy"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"
depends "app"
depends "lb"

recipe "lb_haproxy::setup_server", "This loads the required 'lb' resource using the HAProxy provider."

attribute "lb_haproxy/algorithm",
  :display_name => "Load Balancing Algorithm",
  :description => "The algorithm that the load balancer will use to direct traffic.",
  :required => "optional",
  :default => "roundrobin",
  :choice => ["roundrobin", "leastconn", "source"],
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/timeout_server",
  :display_name => "Server Timeout",
  :description => "The maximum inactivity time on the server side in milliseconds.",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/timeout_client",
  :display_name => "Client Timeout",
  :description => "The maximum inactivity time on the client side milliseconds.",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy::setup_server"
  ]
