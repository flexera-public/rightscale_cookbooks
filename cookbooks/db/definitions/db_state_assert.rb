#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Verify database node state
# Make sure our current_master values are set
# Fail if we think we are a slave, but node state thinks we are a master
#
# @param name [Symbol] Assert the type of server we thing we are. Can be :slave, :master, :either
#
# @raise [RuntimeError] if we are not the server type (:slave or :master) that we expect
define :db_state_assert do

  class Chef::Recipe
    include RightScale::Database::Helper
  end

  db_state_get node

  ruby_block "check database node state" do
    block do
      type = params[:name]
      master_ip = node[:db][:current_master_ip]
      master_uuid = node[:db][:current_master_uuid]
      raise "No master DB set.  Is this database initialized as a #{type.to_s}?" unless master_ip && master_uuid
      raise "FATAL: this slave thinks its master!" if node[:db][:this_is_master] && type == :slave
      raise "FATAL: this server is not a master!" if (node[:db][:this_is_master] == false) && type == :master
    end
  end

end
