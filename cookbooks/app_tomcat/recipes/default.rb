#
# Cookbook Name:: app_tomcat
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "  Setting provider specific settings for tomcat"

node[:app][:provider] = "app_tomcat"
node[:app][:database_name] = node[:app_tomcat][:db_name]
node[:app][:port] = 8000

case node[:platform]
when "ubuntu", "debian"
  case node[:app_tomcat][:db_adapter]
  when "mysql"
    node[:app][:packages] = [
      "ecj-gcj",
      #"java-gcj-compat-dev",
      "tomcat6",
      "tomcat6-admin",
      "tomcat6-common",
      "tomcat6-user",
      "libmysql-java",
      "libtcnative-1"
    ]
  when "postgresql"
    node[:app][:packages] = [
      "ecj-gcj",
      #"java-gcj-compat-dev",
      "tomcat6",
      "tomcat6-admin",
      "tomcat6-common",
      "tomcat6-user",
      "libtcnative-1"
    ]
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
when "centos", "fedora", "suse", "redhat", "redhatenterpriseserver"
  case node[:app_tomcat][:db_adapter]
  when "mysql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native",
      "mysql-connector-java"
    ]
  when "postgresql"
    node[:app][:packages] = [
      "eclipse-ecj",
      "tomcat6",
      "tomcat6-admin-webapps",
      "tomcat6-webapps",
      "tomcat-native"
    ]
  else
    raise "Unrecognized database adapter #{node[:app_tomcat][:db_adapter]}, exiting "
  end
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end


log " Preparing tomcat document root variable"
if node[:repo][:default][:destination].empty?
  log "Your repo/default/destination input is no set. Setting project root to default: /srv/tomcat6/webapps/ "
  node[:app_tomcat][:project_home]= "/srv/tomcat6/webapps/"
else
  node[:app_tomcat][:project_home]= node[:repo][:default][:destination]
end

#Creating new project root directory
directory "#{node[:app_tomcat][:project_home]}" do
  recursive true
end
#Cooking doc root variable
node[:app_tomcat][:docroot] = "#{node[:app_tomcat][:project_home]}/#{node[:app_tomcat][:application_name]}"

# setting app LWRP attribute
node[:app][:destination]="#{node[:app_tomcat][:docroot]}"


rightscale_marker :end
