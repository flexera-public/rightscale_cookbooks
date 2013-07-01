#
# Cookbook Name:: lb_elb
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# @resource lb

include RightScale::ELB::Helper

# Installs the load balancer software on the local instance
action :install do
  log "  Install does not apply to ELB"
end

# Attaches an application server to the local load balancer
action :attach do

  require "right_cloud_api"
  require "cloud/aws/elb/manager"

  log "  Attaching #{node[:ec2][:instance_id]} to" +
    " #{new_resource.service_lb_name}"

  # Creates an interface handle to ELB.
  elb = get_elb_object(
    new_resource.service_account_id,
    new_resource.service_account_secret
  )

  # Verify that the ELB exists.
  existing_elbs = elb.DescribeLoadBalancers["DescribeLoadBalancersResponse"]\
    ["DescribeLoadBalancersResult"]\
    ["LoadBalancerDescriptions"]\
    ["member"]

  # If there is only one ELB in the account, Right Cloud API returns a single
  # Hash in the response and an array is returned if multiple ELBs exist.
  existing_elbs = [existing_elbs] if existing_elbs.is_a?(Hash)

  if selected_elb = existing_elbs.detect { |existing_elb|
    existing_elb["LoadBalancerName"] == new_resource.service_lb_name }
    log "ELB '#{new_resource.service_lb_name}' exists"
  else
    raise "ERROR: ELB '#{new_resource.service_lb_name}' does not exist"
  end

  # Checks if this instance's zone is part of the lb. If not, add it.
  if selected_elb["AvailabilityZones"]["member"].
    include?(node[:ec2][:placement][:availability_zone])
    log "...instance already part of ELB zone"
  else
    log "...activating zone #{node[:ec2][:placement][:availability_zone]}"
    elb.EnableAvailabilityZonesForLoadBalancer({
      "LoadBalancerName" => new_resource.service_lb_name,
      "AvailabilityZones.member" => node[:ec2][:placement][:availability_zone]
    })
  end

  # Opens the backend_port.
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "Open backend_port to allow ELB to connect" do
    port new_resource.backend_port
    enable true
    ip_addr "any"
    action :update
  end

  # Connects the server to ELB.
  log "...registering with ELB"
  elb.RegisterInstancesWithLoadBalancer({
    "LoadBalancerName" => new_resource.service_lb_name,
    "Instances.member" => {"InstanceId" => node[:ec2][:instance_id]}
  })

end

# Attach request from an application server
action :attach_request do

  log "  Attach request for #{node[:ec2][:instance_id]}"

  # Calls the "attach" action
  lb "Attaching to ELB" do
    provider "lb_elb"
    backend_port new_resource.backend_port
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :attach
  end

end

# Detaches an application server from the local load balancer
action :detach do

  require "right_cloud_api"
  require "cloud/aws/elb/manager"

  log "  Detaching #{node[:ec2][:instance_id]} from" +
    " #{new_resource.service_lb_name}"

  # Creates an interface handle to ELB.
  elb = get_elb_object(
    new_resource.service_account_id,
    new_resource.service_account_secret
  )

  # Deregister the server to ELB.
  log "...DE-registering with ELB"
  elb.DeregisterInstancesFromLoadBalancer({
    "LoadBalancerName" => new_resource.service_lb_name,
    "Instances.member" => {"InstanceId" => node[:ec2][:instance_id]}
  })

  # Closes the backend_port.
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "Close backend_port allowing ELB to connect" do
    port new_resource.backend_port
    enable false
    ip_addr "any"
    action :update
  end

end

# Detach request from an application server
action :detach_request do

  log "  Detach request for #{node[:ec2][:instance_id]}"

  # Calls the "detach" action
  lb "Detaching from ELB" do
    provider "lb_elb"
    backend_port new_resource.backend_port
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :detach
  end

end

# Install and configure collectd plugins for the server
action :setup_monitoring do
  log "  Setup monitoring does not apply to ELB"
end

# Restart the load balancer service
action :restart do
  log "  Restart does not apply to ELB"
end
