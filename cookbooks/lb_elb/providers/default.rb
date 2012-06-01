#
# Cookbook Name:: lb_elb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :install do
  log "  Install does not apply to ELB"
end # action :install do

action :attach do

  log "  Attaching #{node[:ec2][:instance_id]} to #{new_resource.service_lb_name}"

  require "right_aws"

  # Create interface handle.
  elb = RightAws::ElbInterface.new(
    new_resource.service_account_id, new_resource.service_account_secret,
    {:endpoint_url => "https://elasticloadbalancing." + node[:ec2][:placement][:availability_zone].gsub(/[a-z]+$/, '') + ".amazonaws.com"}
  )

  # Verify that the ELB exists.
  balancers = elb.describe_load_balancers
  created = balancers.detect { |b| b[:load_balancer_name] == new_resource.service_lb_name }
  raise "ERROR: ELB named #{new_resource.service_lb_name} does not exist" if created.nil?

  # Check if this instance's zone is part of the lb, if not add it.
  unless created[:availability_zones].include?(node[:ec2][:placement][:availability_zone])
    log ".. activating zone #{node[:ec2][:placement][:availability_zone]}"
    elb.enable_availability_zones_for_load_balancer(new_resource.service_lb_name, node[:ec2][:placement][:availability_zone])
  end

  # Open backend_port.
  sys_firewall "Open backend_port to allow ELB to connect" do
    port new_resource.backend_port
    enable true
    ip_addr "any"
    action :update
  end

  # Connect server to ELB.
  log ".. registering with ELB"
  elb.register_instances_with_load_balancer(new_resource.service_lb_name, node[:ec2][:instance_id])

end # action :attach do

action :attach_request do

  log "  Attach request for #{node[:ec2][:instance_id]}"

  lb "Attaching to ELB" do
    provider "lb_elb"
    backend_port new_resource.backend_port
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :attach
  end

end # action :attach_request do

action :detach do

  log "  Detaching #{node[:ec2][:instance_id]}"

  require "right_aws"

  # Create interface handle.
  elb = RightAws::ElbInterface.new(
    new_resource.service_account_id, new_resource.service_account_secret,
    {:endpoint_url => "https://elasticloadbalancing." + node[:ec2][:placement][:availability_zone].gsub(/[a-z]+$/, '') + ".amazonaws.com"}
  )

  # Disconnecting server from ELB.
  log ".. detaching from ELB"
  elb.deregister_instances_with_load_balancer(new_resource.service_lb_name, node[:ec2][:instance_id])

  # Close backend_port.
  sys_firewall "Close backend_port allowing ELB to connect" do
    port new_resource.backend_port
    enable false
    ip_addr "any"
    action :update
  end

end # action :detach do

action :detach_request do

  log "  Detach request for #{node[:ec2][:instance_id]}"

  lb "Detaching from ELB" do
    provider "lb_elb"
    backend_port new_resource.backend_port
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :detach
  end

end # action :detach_request do

action :setup_monitoring do
  log "  Setup monitoring does not apply to ELB"
end # action :setup_monitoring do

action :restart do
  log "  Restart does not apply to ELB"
end # action :restart do
