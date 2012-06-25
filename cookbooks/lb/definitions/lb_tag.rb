#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Installs loadbalancer tags.
define :lb_tag, :action => :publish do

  vhost_name = params[:name] == "" ? "localhost" : params[:name]
  tag_action = params[:action]

  # Define advanced LB configuration tags for application servers if they are present
  if vhost_name.include? 'backend_fqdn' || 'backend_uri_path' || 'backend_pool_name'
    right_link_tag "appserver:#{vhost_name}" do
        action tag_action
    end
  end

  right_link_tag "loadbalancer:#{vhost_name}=app" do
    action tag_action
  end

end
