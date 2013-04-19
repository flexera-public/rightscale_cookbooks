#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Setting up Server to work with Rackconnect
if node[:cloud][:provider] == "rackspace-ng" &&
  node[:etc][:passwd].has_key?(:rackconnect)

  # If we are using rackconnect, setting sys_firewall/enabled to anything
  # other than "enable" or "disable" will make no changes to iptables.
  r = ruby_block "Setting up for Rackconnect" do
    block do
      Chef::Log.info("Bypassing sys_firewall::default")
      node[:sys_firewall][:enabled] = "rackconnect"
    end
    action :nothing
  end
  r.run_action(:create)

end

case node[:sys_firewall][:enabled]
when "enabled"
  log "enabling sys_firewall"
  # See https://github.com/rightscale/cookbooks/blob/master/iptables/recipes/default.rb
  # for the "iptables::default" recipe.
  include_recipe "iptables"

  # Enable the iptables service for CentOS/RedHat
  service "iptables" do
    action :enable
    not_if { node[:platform] == "ubuntu" }
  end

  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "22" # SSH
  sys_firewall "80" # HTTP
  sys_firewall "443" # HTTPS

  if node[:cloud][:provider] == "softlayer"
    # Open ports for SoftLayer monitoring agent
    (48000..48020).each do |port|
      sys_firewall port do
        # Net mask to open to all addresses on the internal 10.*.*.*
        ip_addr "10.0.0.0"
      end
    end
  end
when "disabled"
  log "disabling sys_firewall"
  service "iptables" do
    supports :status => true
    action [:disable, :stop]
  end
else
  # previous recipes could have set the node to anything else
  # in order to make no changes to iptables.
  log "making no changes to sys_firewall"
end

# Increase connection tracking table sizes
#
# Increase the value for the 'conntrack_max' module parameter
# to avoid dropping packets on high-throughput systems.

nf_module_name = "net.netfilter.nf_conntrack_max"

# The ip_conntrack_max is calculated based on the RAM available on
# the VM using this formula: conntrack_max=64*n, where n is the amount
# of RAM in MB.
mem_mb = node[:memory][:total].to_i/1024
nf_conntrack_max = "#{nf_module_name} = #{64*mem_mb}"

log "  Setup IP connection tracking limit: #{nf_conntrack_max}"
bash "Update #{nf_module_name}" do
  flags "-ex"
  code <<-EOH
    echo "#{nf_conntrack_max}" >> /etc/sysctl.conf
    sysctl -e -p /etc/sysctl.conf > /dev/null
  EOH
  not_if { ::File.readlines("/etc/sysctl.conf" ).grep(
    /^\s*#{nf_conntrack_max}/).any? }
end

rightscale_marker :end

