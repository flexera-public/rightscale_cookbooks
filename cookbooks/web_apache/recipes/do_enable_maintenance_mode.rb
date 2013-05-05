#
# Cookbook Name:: web_apache
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# This recipe will enable maintenance mode for Apache
# All RightScale apache vhost erb templates have maintenance mode rewrite rule:
# RewriteCond <%= node[:web_apache][:maintenance_file] %> -f
# RewriteCond %{SCRIPT_FILENAME} !/system/maintenance.html
# RewriteCond %{SCRIPT_FILENAME} !^(.+).(gif|png|jpg|css|js|swf)$
# RewriteRule ^.*$ /system/maintenance.html [L]
#
# Recipe will extract a maintenance.html from maintenance.tar.gz
# which will automatically enable maintenance mode rewrite rule.

rightscale_marker :begin

maintenance_file_dir = ::File.dirname(node[:web_apache][:maintenance_file])

# Creating directory for maintenance page.
directory maintenance_file_dir do
  recursive true
  mode "0755"
end

# Copy archive from cookbook files.
cookbook_file "/tmp/maintenance.tar.gz" do
  cookbook 'web_apache'
  source "maintenance.tar.gz"
  mode "0644"
end

bash "Unpack /tmp/maintenance.tar.gz to #{maintenance_file_dir}" do
  flags "-ex"
  code <<-EOH
    tar xzf /tmp/maintenance.tar.gz -C #{maintenance_file_dir}
  EOH
end

rightscale_marker :end
