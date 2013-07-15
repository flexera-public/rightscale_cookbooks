#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# LB attributes
#
# Below are the attributes defined by the LB resource interface.
#

# Pool name for the load balancer
attribute :pool_name, :kind_of => String, :name_attribute => true

# Attaching/Detaching options

# Backend server ID
attribute :backend_id, :kind_of => String, :default => ""

# IP of the backend server
attribute :backend_ip, :kind_of => String, :default => ""

# Port on which the backend server is listening on
attribute :backend_port, :kind_of => Integer, :default => 8000

# Timeout value for load balancer actions
attribute :timeout, :kind_of => Integer, :default => 60 * 5

# Session stickiness
attribute :session_sticky, :kind_of => String, :default => "true"

# Specific to cloud loadbalancing services

# Load balancer service region
attribute :service_region, :kind_of => String, :default => ""

# Load balancer name
attribute :service_lb_name, :kind_of => String, :default => ""

# Account ID for the service region
attribute :service_account_id, :kind_of => String, :default => ""

# Account secret for the service region
attribute :service_account_secret, :kind_of => String, :default => ""

# Full name for the load balancer pool
attribute :pool_name_full, :kind_of => String, :default => ""

# General LoadBalance Actions
#
# Below are the actions defined by the lb resource interface.
#

# Installs the load balancer software on the local instance. Installs software,
# config files, init files, and sets tags on the instance.
actions :install

# Configures load balancer to answer for specified virtual host. Installs
# configuration files, monitoring, and tags for each vhost the load balancer
# will answer for.
actions :add_vhost

# Attaches an application server to the local load balancer. Attaches
# (adds to load balancer's running config) an application server to the
# load balancer. The attributes are used to specify which application server
# to attach.
actions :attach

# Sends an attach request from an application server to a load balancer.
# The load balancer then runs the 'handle_attach' remote recipe to attach the
# application server.
actions :attach_request

# Detaches an application server from the local load balancer. Detaches
# (removes from the load balancer's running config) an application server from
# the local load balancer. The attributes are used to specify which application
# server to detach.
actions :detach

# Sends a detach request from an application server to a load balancer.
# The load balancer then runs the 'handle_detach' remote recipe to detach the
# application server.
actions :detach_request

# Restarts the load balancer service. Should use the platform's 'service' method
# to restart the service.
actions :restart

# Installs and configures collectd plugins for the server. This is used by the
# RightScale platform to display metrics about the load balancer on the
# RightScale dashboard.
actions :setup_monitoring

# Performs advanced configuration for load balancer. Adds support for complicated
# acls and authorization process.
actions :advanced_configs
