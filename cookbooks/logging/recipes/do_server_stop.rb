#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Stopping logging server"
# Calls the logging service stop command
# See the :stop action details in the logging provider's implementation
# i.e. cookbooks/logging_<provider>/providers/default.rb
logging "default" do
  action :stop
end

rightscale_marker :end
