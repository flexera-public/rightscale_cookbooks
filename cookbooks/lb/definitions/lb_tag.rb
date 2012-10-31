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

  # See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
  right_link_tag "loadbalancer:#{pool_name}=app" do
    action tag_action
  end

end
