# RightScale System Firewall Cookbook

## DESCRIPTION:

Built upon Opscode's 'iptables' cookbook. This cookbook provides a LWRP for
managing access to multiple servers in a deployment using machine tags.

## REQUIREMENTS:

Requires a virtual machine launched from a RightScale managed RightImage.

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Use the `sys_firewall::default` recipe in conjunction with the
  'Firewall' input to enable or disable iptables.
* Use the `sys_firewall::setup_rule` recipe for enabling/disabling
  specific firewall rules.
* Use the `sys_firewall::do_list_rules` recipe to list the existing
  firewall rules set up on the server.

## DETAILS:

### General information

When the firewall is enabled it is completely closed for incoming connections -
only outbound connections are allowed. `sys_firewall::default`
then opens 22, 80 and 443 ports by default
(additionally on SoftLayer 48000..48020 ports are opened on the private 10.*
network for the monitoring agent).

When the firewall is disabled the iptables service is disabled and stopped.

When the firewall is set to "unmanaged" no changes are done to the iptables
service so the cloud provider can manage the firewall rules. RightScale will
not manage the firewall rules in this case.

`sys_firewall::default` recipe increases the value for the
'netfilter.nf_conntrack_max' parameter for CentOS images and
the 'net.ipv4.ip_conntrack_max' for Ubuntu and RHEL images to avoid dropping
packets on high-throughput systems.

### Updating firewall rules using tags

All tag-based actions are scoped to the deployment.

#### Update Action

To open a local port on the private IP to all servers with a given tag use:

    sys_firewall "Open this server's ports to all servers with this 'tag' " do
      machine_tag "servertag:active=true"
      port 3306
      # ip_tag "server:private_ip_0" <= default value if not set
      enable true
      action :update
    end

To open a local port to all servers with a given tag on a specified interface
set the ip_tag to the desired interface.

    sys_firewall "Open this server's ports to all servers with this 'tag' " do
      machine_tag "servertag:active=true"
      port 3306
      ip_tag "server:public_ip_0"
      enable true
      action :update
    end

This can be used when a server is booting to open up access for multiple systems
at once.

#### Update Request Action

To request that all servers with a given tag open a port to a given IP address
use:

    sys_firewall "Reques master DB server to open the port to this slave server" do
      machine_tag "rs_dbrepl:master_instance_uuid=XXXXXXX"
      port 3306
      enable true
      ip_addr node[:cloud][:private_ips][0]
      action :update_request
    end

This can be useful when launching a new server that needs to communicate with
a running server (example: new slave server brought online)

To request that all servers with a given tag close a port to a given IP address
use:

    sys_firewall "Request all app servers close ports to this load balancer" do
      machine_tag "loadbalancer:app=www"
      port 8000
      enable false
      ip_addr node[:cloud][:private_ips][0]
      action :update_request
    end

This can be useful when decommissioning a running server that had previously
requested ports opened.

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
