#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker
# Recipe sets node[:rightscale] variables via attribute and metadata.

# Make sure these inputs are set.
raise "rightscale/instance_uuid must be set" unless node[:rightscale][:instance_uuid]
raise "rightscale/servers/sketchy/hostname must be set" unless node[:rightscale][:servers][:sketchy][:hostname]

log "rightscale/instance_uuid is  #{node[:rightscale][:instance_uuid]}"
log "rightscale/servers/sketchy/hostname is #{node[:rightscale][:servers][:sketchy][:hostname]}"

# See cookbooks/rightscale/recipes/setup_server_tags.rb for the
# "rightscale::setup_server_tags" recipe.
include_recipe "rightscale::setup_server_tags"

# See cookbooks/rightscale/recipes/setup_timezone.rb for the
# "rightscale::setup_timezone" recipe.
include_recipe "rightscale::setup_timezone"

# See cookbooks/rightscale/recipes/setup_monitoring.rb for the
# "rightscale::setup_monitoring" recipe.
include_recipe "rightscale::setup_monitoring"

# See cookbooks/rightscale/recipes/setup_cloud.rb for the
# "rightscale::setup_cloud" recipe.
include_recipe "rightscale::setup_cloud"
