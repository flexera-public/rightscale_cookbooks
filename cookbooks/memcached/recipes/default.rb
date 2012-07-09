#
# Cookbook Name::memcached
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing server tags
#
# The instance is identified as a memcached server.
right_link_tag "memcached_server:active=true"
# The server name so that sorts can be done to get the correct order across app servers.
right_link_tag "memcached_server:uuid=#{node[:rightscale][:instance_uuid]}"
# The instance is associated with a cluster
right_link_tag "memcached_server:cluster=#{node[:memcached][:cluster_id]}"
# The listening port
right_link_tag "memcached_server:port=#{node[:memcached][:tcp_port]}"

log "  Server tags installed."

rightscale_marker :end
