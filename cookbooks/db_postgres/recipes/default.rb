#
# Cookbook Name:: db_postgres
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Setup default values for database resource

rightscale_marker :begin

node[:db][:provider] = "db_postgres"
version="#{node[:db_postgres][:version]}"

case version
when '9.1'
  include_recipe "db_postgres::default_#{version.gsub('.', '_')}"
else
  raise "  Unsupported PostgreSQL version: #{version}"
end

rightscale_marker :end
