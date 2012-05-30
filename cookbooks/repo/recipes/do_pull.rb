#
# Cookbook Name:: repo
#
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


rightscale_marker :begin

# Downloading project repository
repo "default" do
  destination node[:repo][:default][:destination]
  action      node[:repo][:default][:perform_action].to_sym
end

rightscale_marker :end
