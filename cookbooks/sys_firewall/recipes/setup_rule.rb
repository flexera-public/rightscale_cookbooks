#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

rule_ip = node[:sys_firewall][:rule][:ip_address]
rule_ip = (rule_ip == "" || rule_ip.downcase =~ /any/) ? nil : rule_ip
to_enable = (node[:sys_firewall][:rule][:enable] == "enable") ? true : false

# Create protocol array here to handle with "both" input
if node[:sys_firewall][:rule][:protocol] == "both"
  rule_protocol = ["tcp", "udp"]
else
  rule_protocol = [node[:sys_firewall][:rule][:protocol]]
end


# If firewall enabled
if node[:sys_firewall][:enabled] == "enabled"
  rule_ports = []
  # Generate separate rules to each of rule_protocol element
  node[:sys_firewall][:rule][:port].split(/\s*,\s*/).each do |rule_port|
    rule_port = rule_port.to_i
    raise "Invalid port specified: #{rule_port}. Valid range 1-65536" \
      unless rule_port > 0 and rule_port <= 65536
    rule_ports << rule_port
  end

  rule_protocol.each do |proto|
    rule_ports.each do |rule_port|
      # See cookbooks/sys_firewall/providers/default.rb for the "update" action
      sys_firewall rule_port.to_i do
        ip_addr rule_ip
        protocol proto
        enable to_enable
        action :update
      end
    end
  end
else
  log "  Firewall not enabled. Not adding rule for #{rule_port}."
end
