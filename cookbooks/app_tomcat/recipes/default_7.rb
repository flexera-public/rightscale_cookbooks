#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

version="7"
log "  Setting Tomcat version to #{version}"

log "  Setting provider specific settings for tomcat"
node[:app][:provider] = "app_tomcat"
node[:app_tomcat][:version] = version
node[:app][:database_name] = node[:app_tomcat][:db_name]

# Preparing list of database adapter packages depending on platform and database adapter
case node[:platform]
when "centos"
  case node[:app_tomcat][:db_adapter]
  when "mysql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "ecj3",
      "tomcat7",
      "tomcat7-admin-webapps",
      "tomcat7-webapps",
      "tomcat-native",
      "mysql-connector-java"
    ]
  when "postgresql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "ecj3",
      "tomcat7",
      "tomcat7-admin-webapps",
      "tomcat7-webapps",
      "tomcat-native"
    ]
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unsupported platform #{node[:platform]} for Tomcat Version #{version}"
end

# Setting app LWRP attribute
node[:app][:root] = "#{node[:repo][:default][:destination]}/#{node[:web_apache][:application_name]}"
# tomcat shares the same doc root with the application destination
node[:app][:destination]="#{node[:app][:root]}"

  # Adding custmized repo for tomcat7 rpm, later when these rpm are part of the mirror, it should be removed
  template "/etc/yum.repos.d/tomcat7.repo" do
    source "tomcat7.repo.erb"
    owner "root"
    group "root"
    mode "0644"
    cookbook "app_tomcat"
  end

directory "#{node[:app][:destination]}" do
  recursive true
end

rightscale_marker :end
