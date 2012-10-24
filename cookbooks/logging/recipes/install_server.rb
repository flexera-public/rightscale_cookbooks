#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Included recipe would determine the syslog provider and setup the default values for logging resource.
include_recipe "logging::default"

# Configures a logging server
logging "default" do
  action :configure_server
end

rightscale_marker :end
