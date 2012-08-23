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

# Prepare user data to use in LWRP
# Example: node[:lb][:advanced_config][:backend_authorized_users] = "/serverid{admin:123, admin2:345}; /appserver{user1:678}"
if node[:lb][:advanced_config][:backend_authorized_users]
  base_string = node[:lb][:advanced_config][:backend_authorized_users]
  entry_items = base_string.gsub(/\s+/, "").split(";")

  entry_items.each do |record|
    # example: "/serverid{admin:password, admin2:password2}
    auth_array=record.match(/^(.+)\{(.+)\}/)
    # users_array = [ "admin:password", "admin2:password2" ]
    users_array = auth_array[2].split(",")
    # backend_short_name = "_serverid"
    backend_short_name = auth_array[1].gsub(/[\/]/, '_')

    lb backend_short_name do
      backend_authorized_users users_array
      action :advanced_configs
    end

  end
end


rightscale_marker :end
