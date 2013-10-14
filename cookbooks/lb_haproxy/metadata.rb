maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale load balancer cookbook for Apache/HAProxy. This" +
                 " cookbook provides recipes for setting up and running an" +
                 " Apache/HAProxy load balancer server as well as recipes for" +
                 " attaching and detaching application servers."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "app"
depends "lb"

recipe "lb_haproxy::setup_server",
  "This loads the required 'lb' resource using the HAProxy provider."

attribute "lb_haproxy/algorithm",
  :display_name => "Load Balancing Algorithm",
  :description =>
    "The algorithm that the load balancer will use to direct traffic." +
    " Example: roundrobin",
  :required => "optional",
  :default => "roundrobin",
  :choice => ["roundrobin", "leastconn", "source"],
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/timeout_server",
  :display_name => "Server Timeout",
  :description =>
    "The maximum inactivity time on the server side to direct traffic." +
    " Example: 60000",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/timeout_client",
  :display_name => "Client Timeout",
  :description =>
    "The maximum inactivity time on the client side in milliseconds." +
    " Example: 60000",
  :required => "optional",
  :default => "60000",
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/httpclose",
  :display_name => "Passive HTTP connection closing",
  :description =>
    "By default, when a client communicates with a server, HAProxy will only" +
    " analyze, log, and process the first request of each connection. If" +
    " option httpclose is set, it will check if a 'Connection: close'" +
    " header is already set in each direction, and will add one if missing." +
    " Default: on",
  :required => "optional",
  :choice => ["on", "off"],
  :default => "on",
  :recipes => [
    "lb_haproxy::setup_server"
  ]

attribute "lb_haproxy/abortonclose",
  :display_name => "Early dropping of aborted requests pending in queues",
  :description =>
    "By default (without the option) the behaviour is HTTP compliant and" +
    " aborted requests will be served. But when the option is specified, a" +
    " session with an incoming channel closed will be aborted while it is" +
    " still possible, either pending in the queue for a connection slot, or" +
    " during the connection establishment if the server has not yet" +
    " acknowledged the connection request. Default: off",
  :required => "optional",
  :choice => ["on", "off"],
  :default => "off",
  :recipes => [
    "lb_haproxy::setup_server"
  ]
