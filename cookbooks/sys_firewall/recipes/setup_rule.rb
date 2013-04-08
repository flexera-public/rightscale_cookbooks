#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# convert inputs into parameters usable by the firewall_rule definition
rule_port = node[:sys_firewall][:rule][:port].to_i
raise "Invalid port specified: #{node[:sys_firewall][:rule][:port]}. Valid range 1-65536" unless rule_port > 0 and rule_port <= 65536

rule_ip = node[:sys_firewall][:rule][:ip_address]
rule_ip = (rule_ip == "" || rule_ip.downcase =~ /any/) ? nil : rule_ip
to_enable = (node[:sys_firewall][:rule][:enable] == "enable") ? true : false

# Create protocol array here to handle with "both" input
if node[:sys_firewall][:rule][:protocol] == "both"
  rule_protocol = ["tcp", "udp"]
else
  rule_protocol = [node[:sys_firewall][:rule][:protocol]]
end


# if firewall enabled
if node[:sys_firewall][:enabled] == "enabled"
  # generate separate rules to each of rule_protocol element
  rule_protocol.each do |proto|
    # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
    sys_firewall rule_port do
      ip_addr rule_ip
      protocol proto
      enable to_enable
      action :update
    end
  end
else
  log "  Firewall not enabled. Not adding rule for #{rule_port}."
end

rightscale_marker :end
