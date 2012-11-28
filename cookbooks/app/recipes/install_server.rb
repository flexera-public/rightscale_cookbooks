#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin
if node[:cloud][:public_ips][1]
  node[:app][:backend_ip_type] == "Public" ?  node[:app][:ip] = node[:cloud][:public_ips][0] : node[:app][:ip] = node[:cloud][:private_ips][0]
else
  log " No public IP detected. Forcing to first private: #{node[:cloud][:private_ips][0]}"
  node[:app][:ip] = node[:cloud][:private_ips][0]
end

log "  Provider is #{node[:app][:provider]}"
log "  Application IP is #{node[:app][:ip]}"
log "  Application port is #{node[:app][:port]}"

# Setting app LWRP attribute
node[:app][:destination] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"

directory "#{node[:app][:destination]}" do
  recursive true
end


log "  Installing #{node[:app][:packages]}" if node[:app][:packages]

# Setup default values for application resource and install required packages
# See cookbooks/app_<providers>/providers/default.rb for the "install" action.
app "default" do
  persist true
  provider node[:app][:provider]
  packages node[:app][:packages]
  action :install
end

if node[:app][:provider] == "app_passenger"
  node[:app][:root] = node[:app][:destination] + "/public"
else
  node[:app][:root]="#{node[:app][:destination]}"
end

# Let others know we are an appserver
# See http://support.rightscale.com/12-Guides/Chef_Cookbooks_Developer_Guide/Chef_Resources#RightLinkTag for the "right_link_tag" resource.
right_link_tag "appserver:active=true"
right_link_tag "appserver:listen_ip=#{node[:app][:ip]}"
right_link_tag "appserver:listen_port=#{node[:app][:port]}"

rightscale_marker :end
