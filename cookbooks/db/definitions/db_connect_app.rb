#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Sets up config file to connect application servers with database servers.
#
# @param [String] template Name of template that sets up the config file.
# @param [String] cookbook Name of cookbook that called this definition.
# @param [String] database Name of the database.
# @param [String] driver_type Type of driver to configure.
# @param [String] owner The name of the owner.
# @param [String] group The name of the group the owner belongs to.
# @param [Hash] vars Additional variables required in the template.
define :db_connect_app, :template => "db_connection_example.erb", :cookbook => "db", :database => nil, :driver_type => nil, :owner => nil, :group => nil, :vars => {} do

  # The action "install_client_driver" is implemented in db_<provider> cookbook's provider/default.rb
  db node[:db][:data_dir] do
    driver_type params[:driver_type]
    action :install_client_driver
  end

  log "!! connect app db port is #{node[:db][:port]}"

  template params[:name] do
    source params[:template]
    cookbook params[:cookbook]
    mode "0440"
    owner params[:owner]
    group params[:group]
    backup false
    variables(
      :user => node[:db][:application][:user],
      :password => node[:db][:application][:password],
      :fqdn => node[:db][:dns][:master][:fqdn],
      :socket => node[:db][:socket],
      :driver => node[:db][:client][:driver],
      :database => params[:database],
      :listen_port => node[:db][:port],
      :vars => params[:vars]
    )
  end

end
