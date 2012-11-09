#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# This recipe will enable maintenance mode for Apache
# All RightScale apache vhost erb templates have maintenance mode rewrite rule:
# RewriteCond %{DOCUMENT_ROOT}/system/maintenance.html -f
# RewriteCond %{SCRIPT_FILENAME} !/system/maintenance.html
# RewriteCond %{SCRIPT_FILENAME} !^(.+).(gif|png|jpg|css|js|swf)$
# RewriteRule ^.*$ /system/maintenance.html [L]
#
# Recipe will copy cookbook default or user specified /maintenance.html to
# apache doc root /system/maintenance.html.
# This will automatically enable maintenance mode rewrite rule.

rightscale_marker :begin

# Creating directory for maintenance page
directory "#{node[:web_apache][:docroot]}/system/" do
  recursive true
  mode "0755"
end

# Applying default maintenance.html if maintenance_file input is empty.

# Copy archive from cookbook files
cookbook_file "/tmp/maintenance.tar.gz" do
  cookbook 'web_apache'
  source "maintenance.tar.gz"
  mode "0644"
  only_if do node[:web_apache][:maintenance_file].empty? end
end

bash "Unpack /tmp/maintenance.tar.gz to #{node[:web_apache][:docroot]}/system/" do
  flags "-ex"
  code <<-EOH
    tar xzf /tmp/maintenance.tar.gz -C #{node[:web_apache][:docroot]}/system/
  EOH
  only_if do node[:web_apache][:maintenance_file].empty? end
end

bash "Applying user defined maintenance.html file" do
  flags "-ex"
  code <<-EOH
    cp -f #{node[:web_apache][:maintenance_file]} #{node[:web_apache][:docroot]}/system/maintenance.html
  EOH
  not_if do node[:web_apache][:maintenance_file].empty? end
end

rightscale_marker :end
