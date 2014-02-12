#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Grants privileges to db accounts using 'roles' to combine these privileges,
#   eg 'admin' and 'application' roles.
#
# @param database [String] Database name for which the privileges need to be set.
#
define :db_set_privileges, :database => "*.*" do

  params[:name].each do |user|
    log "  Setting #{user[:role]} privileges."
    # See cookbooks/db_<provider>/providers/default.rb for the "set_privileges" action.
    db node[:db][:data_dir] do
      privilege user[:role]
      privilege_username user[:username]
      privilege_password user[:password]
      privilege_database params[:database]
      action :set_privileges
    end
  end

end


