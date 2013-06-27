#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Logs 'node[:rightscale][:instance_uuid]'. Raises an Exception if it isn't set.
if node[:rightscale][:instance_uuid].to_s.empty?
  raise "'node[:rightscale][:instance_uuid]' must be set!"
else
  log "  Instance UUID: #{node[:rightscale][:instance_uuid]}"
end

# Logs 'node[:rightscale][:servers][:sketchy][:hostname]'.
# Raises an Exception if it isn't set.
if node[:rightscale][:servers][:sketchy][:hostname].to_s.empty?
  raise "'node[:rightscale][:servers][:sketchy][:hostname]' must be set!"
else
  log "  Sketchy hostname: #{node[:rightscale][:servers][:sketchy][:hostname]}"
end

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
