#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

directory "#{node[:jenkins][:server][:home]}/plugins" do
  mode 0755
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  only_if { node[:jenkins][:server][:plugins] }
end

service "jenkins" do
  action :stop
end

unless node[:jenkins][:server][:plugins].to_s == ""
  node[:jenkins][:server][:plugins_array] = node[:jenkins][:server][:plugins].gsub(/\s+/, "").split(",")

  node[:jenkins][:server][:plugins_array].each do |name|
  remote_file "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi" do
    source "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
    backup false
    mode 0644
    owner node[:jenkins][:server][:system_user]
    group node[:jenkins][:server][:system_group]
    # action :nothing
  end

# BROKEN: http_request: http://tickets.opscode.com/browse/CHEF-3218
#
#   class Chef::REST
#     include RightScale::Jenkins::HttpRequestHelper
#   end

#   http_request "HEAD #{node[:jenkins][:mirror]}/latest/#{name}.hpi" do
#     message ""
#     url "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
#     action :head
#     if File.exists?("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi")
#       headers "If-Modified-Since" => File.mtime("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi").httpdate
#     end
#     notifies :create, resources(:remote_file => "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi"), :immediately
#   end
#   end
# end

service "jenkins" do
  action :start
end

rightscale_marker :end