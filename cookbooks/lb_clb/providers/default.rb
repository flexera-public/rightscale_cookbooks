#
# Cookbook Name:: lb_clb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

action :install do
  log "  Install does not apply to CLB"
end

action :attach do

  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip}"

  script_directory = "/home/lb"
  attach_script = script_directory + "/clb_attach.sh"

  directory script_directory do
    owner "root"
    group "root"
    action :create
    recursive true
  end

  # Open backend_port.
  sys_firewall "Open backend_port to allow CLB to connect" do
    port new_resource.backend_port
    enable true
    ip_addr "any"
    action :update
  end

  # Generate script to add to CLB.
  template attach_script do
    source 'clb_attach_exec.erb'
    owner 'root'
    group 'root'
    mode 0700
    backup false
    cookbook "lb_clb"
    variables(
      :backend_ip => new_resource.backend_ip,
      :backend_port => new_resource.backend_port,
      :clb_region => new_resource.service_region,
      :clb_name => new_resource.service_lb_name
    )
  end

  # Run the script to connect server to CLB.
  execute "attach_script" do
    command attach_script
    action :run
    environment ({
      'RACKSPACE_API_TOKEN' => new_resource.service_account_secret,
      'RACKSPACE_USERNAME' => new_resource.service_account_id
    })
  end

  # Clean up script.
  file attach_script do
    action :delete
    backup false
  end

end

action :attach_request do

  log "  Attach request for #{new_resource.backend_ip}"

  lb "Attaching to CLB" do
    provider "lb_clb"
    backend_ip new_resource.backend_ip
    backend_port new_resource.backend_port
    service_region new_resource.service_region
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :attach
  end

end

action :detach do

  log "  Attaching #{new_resource.backend_ip}"

  script_directory = "/home/lb"
  detach_script = script_directory + "/clb_detach.sh"

  directory script_directory do
    owner "root"
    group "root"
    action :create
    recursive true
  end

  # Generate script to remote from CLB.
  template detach_script do
    source 'clb_detach_exec.erb'
    owner 'root'
    group 'root'
    mode 0700
    backup false
    cookbook "lb_clb"
    variables(
      :backend_ip => new_resource.backend_ip,
      :clb_region => new_resource.service_region,
      :clb_name => new_resource.service_lb_name
    )
  end

  # Run the script to connect server to CLB.
  execute "detach_script" do
    command detach_script
    action :run
    environment ({
      'RACKSPACE_API_TOKEN' => new_resource.service_account_secret,
      'RACKSPACE_USERNAME' => new_resource.service_account_id
    })
  end

  # Clean up script.
  file detach_script do
    action :delete
    backup false
  end

  # Close backend_port.
  sys_firewall "Close backend_port allowing CLB to connect" do
    port new_resource.backend_port
    enable false
    ip_addr "any"
    action :update
  end

end

action :detach_request do

  log "  Detach request for #{new_resource.backend_ip}"

  lb "Detaching from CLB" do
    backend_ip new_resource.backend_ip
    backend_port new_resource.backend_port
    service_region new_resource.service_region
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :detach
  end

end

action :setup_monitoring do
  log "  Setup monitoring does not apply to CLB"
end

action :restart do
  log "  Restart does not apply to CLB"
end
