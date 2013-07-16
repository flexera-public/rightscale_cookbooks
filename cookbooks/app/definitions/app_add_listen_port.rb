#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Adds a port to the apache listen ports.conf file and node attribute
# The node[:apache][:listen_ports] is an array of strings for the webserver to listen on.
# Update this array with the provided port unless it already exists in the array.
# Then update the apache port.conf file. If the ports are already configured correctly
# nothing happens.

define :app_add_listen_port do

  # listens_ports is an array of strings, make sure to compare string to string, not string to integer.
  port_str = params[:name].to_s
  node[:apache][:listen_ports] << port_str unless node[:apache][:listen_ports].include?(port_str)
  log "Apache listen ports: #{node[:apache][:listen_ports].inspect}"

  # Creating ports.conf for apache which will contain all ports apache listen on.
  template "#{node[:apache][:dir]}/ports.conf" do
    cookbook "apache2"
    source "ports.conf.erb"
    variables(
      :apache_listen_ports => node[:apache][:listen_ports]
    )
    notifies :restart, resources(:service => "apache2")
  end

end
