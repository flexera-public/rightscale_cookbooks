#
# Cookbook Name:: sys_firewall
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if node[:sys_firewall][:enabled] == "enabled"
  # See https://github.com/rightscale/cookbooks/blob/master/iptables/recipes/default.rb for the "iptables::default" recipe.
  include_recipe "iptables"
  # See cookbooks/sys_firewall/providers/default.rb for the "update" action.
  sys_firewall "22" # SSH
  sys_firewall "80" # HTTP
  sys_firewall "443" # HTTPS

  if node[:cloud][:provider] == "softlayer"
    # Open ports for SoftLayer monitoring agent
    (48000..48020).each do |port|
      sys_firewall port do
        ip_addr "10.0.0.0" # Net mask to open to all addresses on the internal 10.*.*.*
      end
    end
  end

else
  service "iptables" do
    supports :status => true
    action [:disable, :stop]
  end
end


# Increase connection tracking table sizes
#
# Increase the value for the 'conntrack_max' module parameter
# to avoid dropping packets on high-throughput systems.

nf_module_name = value_for_platform(
  "centos" => {
    "default" => "net.netfilter.nf_conntrack_max"
  },
  "default" => "net.ipv4.ip_conntrack_max"
)

# The ip_conntrack_max is calculated based on the RAM available on
# the VM using this formula: conntrack_max=64*n, where n is the amount
# of RAM in MB.
GB=1024*1024
mem_mb = node[:memory][:total].to_i/1024
nf_conntrack_max = "#{nf_module_name} = #{64*mem_mb}"

log "  Setup IP connection tracking limit: #{nf_conntrack_max}"
bash "Update #{nf_module_name}" do
  flags "-ex"
  code <<-EOH
    echo "#{nf_conntrack_max}" >> /etc/sysctl.conf
    sysctl -e -p /etc/sysctl.conf > /dev/null
  EOH
  not_if { ::File.readlines("/etc/sysctl.conf").grep("#{nf_conntrack_max}\n").any? }
end

# Update iptables config file to not to reset nf_* modules to its default values
template "/etc/sysconfig/iptables-config" do
  source "iptables_config.erb"
  cookbook "sys_firewall"
  not_if { node[:platform] == "ubuntu" }
end

# Rebuild iptables
execute "rebuild-iptables" do
  command "/usr/sbin/rebuild-iptables"
end

rightscale_marker :end
