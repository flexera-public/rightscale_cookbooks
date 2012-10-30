#
# Cookbook Name:: lb_haproxy
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

class Chef::Recipe
  include RightScale::App::Helper
end

# See cookbooks/app/libraries/helper.rb for the "pool_names" method.
pool_names(node[:remote_recipe][:pools]).each do |pool_name|
  # See cookbooks/lb_<provider>/providers/default.rb for the "advanced_configs" action.
  lb pool_name do
    action :advanced_configs
  end
end

rightscale_marker :end
