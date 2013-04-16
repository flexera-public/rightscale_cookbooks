#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Set up all db/dump/* attributes
dumpfilename = node[:db][:dump][:prefix] + "-" + Time.now.strftime("%Y%m%d%H%M") + ".gz"
dumpfilepath = "/tmp/#{dumpfilename}"

databasename = node[:db][:dump][:database_name]

container = node[:db][:dump][:container]
cloud = node[:db][:dump][:storage_account_provider]

# Execute the command to create the dumpfile
# See cookbooks/db_<provider>/providers/default.rb for the "generate_dump_file" action.
db node[:db][:data_dir] do
  dumpfile dumpfilepath
  db_name databasename
  action :generate_dump_file
end

# Overrides default endpoint or for generic storage clouds such as Swift.
# Is set as ENV['STORAGE_OPTIONS'] for ros_util.
require 'json'

options =
  if node[:db][:dump][:storage_account_endpoint].to_s.empty?
    {}
  else
    {'STORAGE_OPTIONS' => JSON.dump({
      :endpoint => node[:db][:dump][:storage_account_endpoint],
      :cloud => node[:db][:dump][:storage_account_provider].to_sym
    })}
  end

environment_variables = {
  'STORAGE_ACCOUNT_ID' => node[:db][:dump][:storage_account_id],
  'STORAGE_ACCOUNT_SECRET' => node[:db][:dump][:storage_account_secret]
}.merge(options)

# Upload the files to ROS
execute "Upload dumpfile to Remote Object Store" do
  command "/opt/rightscale/sandbox/bin/ros_util put --cloud #{cloud} --container #{container} --dest #{dumpfilename} --source #{dumpfilepath}"
  environment environment_variables
end

# Delete the local file
file dumpfilepath do
  backup false
  action :delete
end

rightscale_marker :end
