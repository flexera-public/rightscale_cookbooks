#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :db_connect_app, :template => "db_connection_example.erb", :cookbook => "db", :database => nil, :driver_type => nil, :owner => nil, :group => nil, :vars => {} do

  db node[:db][:data_dir] do
    driver_type params[:driver_type]
    action :install_client_driver
  end
  
  template params[:name] do
    source params[:template]
    cookbook params[:cookbook]
    mode 0440
    owner params[:owner]
    group params[:group]
    backup false
    variables(
      :user => node[:db][:application][:user],
      :password => node[:db][:application][:password],
      :fqdn => node[:db][:dns][:master][:fqdn],
      :socket => node[:db][:socket],
      :driver => node[:db][:client_driver],
      :database => params[:database],
      :datasource => params[:datasource]
    )
  end

end


