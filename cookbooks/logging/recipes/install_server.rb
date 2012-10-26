#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# The included recipe determines the syslog provider and sets up the default value for the logging resource.
include_recipe "logging::default"

# Configures a logging server
# See the :configure_server action details in the logging provider's implementation
# i.e. cookbooks/logging_<provider>/providers/default.rb
logging "default" do
  action :configure_server
end

rightscale_marker :end
