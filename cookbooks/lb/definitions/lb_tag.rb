#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Installs loadbalancer tags.
define :lb_tag, :action => :publish do

  pool_name = params[:name] == "" ? "localhost" : params[:name]
  tag_action = params[:action]

  right_link_tag "loadbalancer:#{pool_name}=app" do
    action tag_action
  end

end
