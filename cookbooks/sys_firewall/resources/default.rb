#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Updates firewall rules on the servers
actions :update

# Requests firewall rule update on the servers
actions :update_request

# Firewall port
attribute :port, :kind_of => Integer # Can also be passed as resource name

# Protocol for the port specified
attribute :protocol, :equal_to => ["tcp", "udp", "both"], :default => "tcp"

# Enable/Disable firewall
attribute :enable, :equal_to => [true, false], :default => true

# Range of IP addresses that will be allowed or denied access by firewall
attribute :ip_addr, :kind_of => String, :default => "any"

# Sets regex for identifying machine tags in servers on which remote_recieps can
# be run
attribute :machine_tag, :kind_of => String, :regex => /^([^:]+):(.+)=.+/

# Sets the IP interface on which the server listens. Example: public_ip_0, private_ip_0
attribute :ip_tag, :kind_of => String, :regex => /server:(.+)/

# Server collection
attribute :collection, :kind_of => String, :default => "sys_firewall"

# Defines a default action
def initialize(*args)
  super
  @action = :update
end
