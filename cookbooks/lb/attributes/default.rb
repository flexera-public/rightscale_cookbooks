# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Required attributes that determine which provider to use.
set_unless[:lb][:service][:provider] = "lb_haproxy"

# Logical name for the application (balancing group) to use.
set_unless[:lb][:pools] = nil
set_unless[:lb][:host]= nil
set_unless[:server_collection]['app_servers'] = Hash.new

# The address that load balancer should bind to.
set_unless[:lb][:bind_address] = "127.0.0.1"
# Port that load balancer should bind to.
set_unless[:lb][:bind_port] = 85

# URI for the load balancer to use to check the health of a server (only used when using http templates).
set_unless[:lb][:health_check_uri] = "/"
# URI that the load balancer uses to publish its status.
set_unless[:lb][:stats_uri] = ""
# Username required to access to the haproxy stats page.
set_unless[:lb][:stats_user] = ""
# Password required to access to the haproxy stats page.
set_unless[:lb][:stats_password] = ""
set_unless[:lb][:vhost_port] = ""
set_unless[:lb][:session_stickiness] = ""
set_unless[:lb][:max_conn_per_server] = "500"
# Reconverge cron times. Set the minute to a random number so reconverges are spread out.
set_unless[:lb][:cron_reconverge_hour] = "*"
set_unless[:lb][:cron_reconverge_minute] = "#{5+rand(50)}"

# Stores the list of application servers being loadbalanced.
set_unless[:lb][:appserver_list] = {}

# Sets the web service name based on OS if they are not already set.
case platform
when "redhat", "centos"
  set_unless[:lb][:apache_name] = "httpd"
else
  set_unless[:lb][:apache_name] = "apache2"
end
