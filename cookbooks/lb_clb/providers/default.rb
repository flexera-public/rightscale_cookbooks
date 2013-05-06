#
# Cookbook Name:: lb_clb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# @resource lb

# Installs the load balancer software on the local instance
action :install do
  log "  Install does not apply to CLB"
end

# Attaches an application server to the local load balancer
action :attach do
  log "  Attaching #{new_resource.backend_id} / #{new_resource.backend_ip}"

  script_directory = "/home/lb"
  attach_script = script_directory + "/clb_attach.sh"

  # Creates directory for script
  directory script_directory do
    owner "root"
    group "root"
    action :create
    recursive true
  end

  # Opens the backend_port.
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "Open backend_port to allow CLB to connect" do
    port new_resource.backend_port
    enable true
    ip_addr "any"
    action :update
  end

  # Generates script to add to CLB.
  template attach_script do
    source 'clb_attach_exec.erb'
    owner 'root'
    group 'root'
    mode "0700"
    backup false
    cookbook "lb_clb"
    variables(
      :backend_ip => new_resource.backend_ip,
      :backend_port => new_resource.backend_port,
      :clb_region => new_resource.service_region,
      :clb_name => new_resource.service_lb_name
    )
  end

  # Runs the script to connect server to CLB.
  execute "attach_script" do
    command attach_script
    action :run
    environment ({
      'RACKSPACE_API_TOKEN' => new_resource.service_account_secret,
      'RACKSPACE_USERNAME' => new_resource.service_account_id
    })
  end

  # Cleans up script.
  file attach_script do
    action :delete
    backup false
  end
end

# Attach request from an application server
action :attach_request do
  log "  Attach request for #{new_resource.backend_ip}"

  # Calls the "attach" action
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

# Detaches an application server from the local load balancer
action :detach do
  log "  Attaching #{new_resource.backend_ip}"

  script_directory = "/home/lb"
  detach_script = script_directory + "/clb_detach.sh"

  # Creates directory for script
  directory script_directory do
    owner "root"
    group "root"
    action :create
    recursive true
  end

  # Generates script to remote from CLB.
  template detach_script do
    source 'clb_detach_exec.erb'
    owner 'root'
    group 'root'
    mode "0700"
    backup false
    cookbook "lb_clb"
    variables(
      :backend_ip => new_resource.backend_ip,
      :clb_region => new_resource.service_region,
      :clb_name => new_resource.service_lb_name
    )
  end

  # Runs the script to connect server to CLB.
  execute "detach_script" do
    command detach_script
    action :run
    environment ({
      'RACKSPACE_API_TOKEN' => new_resource.service_account_secret,
      'RACKSPACE_USERNAME' => new_resource.service_account_id
    })
  end

  # Cleans up script.
  file detach_script do
    action :delete
    backup false
  end

  # Closes the backend_port.
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "Close backend_port allowing CLB to connect" do
    port new_resource.backend_port
    enable false
    ip_addr "any"
    action :update
  end
end

# Detach request from an application server
action :detach_request do

  log "  Detach request for #{new_resource.backend_ip}"

  # Calls the "detach" action
  lb "Detaching from CLB" do
    provider "lb_clb"
    backend_ip new_resource.backend_ip
    backend_port new_resource.backend_port
    service_region new_resource.service_region
    service_lb_name new_resource.service_lb_name
    service_account_id new_resource.service_account_id
    service_account_secret new_resource.service_account_secret
    action :detach
  end

end

# Install and configure collectd plugins for the server
action :setup_monitoring do
  log "  Setup monitoring does not apply to CLB"
end

# Restart the load balancer service
action :restart do
  log "  Restart does not apply to CLB"
end
