#
# Cookbook Name:: rightscale
# 
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :rightscale_enable_collectd_plugin do
  if params[:name]
    node[:rightscale][:plugin_list_array] << params[:name] unless node[:rightscale][:plugin_list_array].include?(params[:name])
  end
end
