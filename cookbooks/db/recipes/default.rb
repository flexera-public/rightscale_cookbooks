#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Setup default values for database resource
#
db node[:db][:data_dir] do
  persist true
  provider node[:db][:provider]
  action :nothing
end

rightscale_marker :end
