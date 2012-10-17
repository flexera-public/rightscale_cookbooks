# 
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# LB attributes
#
# Below are the attributes defined by the LB resource interface.
#

attribute :pool_name, :kind_of => String, :name_attribute => true

# Attaching/Detaching options
attribute :backend_id, :kind_of => String, :default => ""
attribute :backend_ip, :kind_of => String, :default => ""
attribute :backend_port, :kind_of => Integer, :default => 8000
attribute :timeout, :kind_of => Integer, :default => 60 * 5
attribute :session_sticky, :kind_of => String, :default => "true"

# Specific to cloud loadbalancing services
attribute :service_region, :kind_of => String, :default => ""
attribute :service_lb_name, :kind_of => String, :default => ""
attribute :service_account_id, :kind_of => String, :default => ""
attribute :service_account_secret, :kind_of => String, :default => ""

attribute :pool_name_full, :kind_of => String, :default => ""

# General LoadBalance Actions
#
# Below are the actions defined by the lb resource interface.
#

# Install
# Installs the load balancer software on the local instance.
#
# Installs software, config files, init files, and sets tags on the instance.
#
actions :install

# Add Vhost
# Configures load balancer to answer for specified virtual host
#
# Installs configuration files, monitoring, and tags for each vhost the load balancer will
# answer for.
#
actions :add_vhost

# Attach
# Attaches an application server to the local load balancer.
#
# Attaches (adds to load balancer's running config) an application server to
# the load balancer.  The attributes are used to specify which application server to attach.
#
actions :attach

# Attach Request
# Attach request from an application server.
#
# This runs on an application server which then runs a remote recipe on the
# remote load balancer.  The remote recipe eventually runs the 'attach' action.
#
actions :attach_request

# Detach
# Detaches an application server from the local load balancer.
#
# Detaches (removes from the load balancer's running config) an application server from
# the local load balancer.  The attributes are used to specify which application server to detach.
#
actions :detach

# Detach Request
# Detach request from an application server.
#
# This runs on an application server which then runs a remote recipe on the
# remote load balancer.  The remote recipe eventually runs the 'detach' action.
#
actions :detach_request

# Restart
# Restart the load balancer service.
#
# Should use the platform's 'service' method to restart the service.
#
actions :restart

# Setup Monitoring
# Install and configure collectd plugins for the server.
#
# This is used by the RightScale platform to display metrics about the
# load balancer on the RightScale dashboard.
#
actions :setup_monitoring

# Advanced Configs
# Perform advanced configuration for load balancer.
#
#add support for complicated acls and authorization process
actions :advanced_configs
