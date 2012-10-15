#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_set_privileges, :database => "*.*" do

  params[:name].each do |role, role_cred_values|
    log "  Setting #{role} privileges."
    db node[:db][:data_dir] do
      privilege role
      privilege_username role_cred_values[0]
      privilege_password role_cred_values[1]
      privilege_database params[:database]
      action :set_privileges
    end
  end

end


