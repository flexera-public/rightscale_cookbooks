#
# Cookbook Name:: rightscale.
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.
 
 
# Sets node[:rightscale] variables via attribute and metadata.
rightscale_marker :begin
 
# Make sure these inputs are set.
raise "rightscale/instance_uuid must be set" unless node[:rightscale][:instance_uuid]
raise "rightscale/servers/sketchy/hostname must be set" unless node[:rightscale][:servers][:sketchy][:hostname]
 
log "rightscale/instance_uuid is  #{node[:rightscale][:instance_uuid]}"
log "rightscale/servers/sketchy/hostname is #{node[:rightscale][:servers][:sketchy][:hostname]}"

case node[:platform]
  when "ubuntu", "debian"
    node[:rightscale][:collectd_packages] = ["collectd","collectd-core","collectd-utils","libcollectdclient0"]
    node[:rightscale][:collectd_packages_version] = "4.10.1-2"
  when "centos","redhat"
    node[:rightscale][:collectd_packages] = ["collectd"]
    node[:rightscale][:collectd_packages_version] = "4.10.0-4.el5"
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

include_recipe "rightscale::setup_server_tags"
include_recipe "rightscale::setup_timezone"
include_recipe "rightscale::setup_logging"
include_recipe "rightscale::setup_mail"
include_recipe "rightscale::setup_monitoring"

rightscale_marker :end
