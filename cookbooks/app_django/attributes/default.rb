#
# Cookbook Name:: app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# Setting Django version
set[:app_django][:version] = "1.4"

# By default django uses MySQL as the DB adapter
set_unless[:app][:db_adapter] = "mysql"
# Path to html maintenance page, which will be displayed, when main application is unavailable
set_unless[:app_django][:apache][:maintenance_page]=""
# By default apache will serve any existing local files directly (except actionable ones)
set_unless[:app_django][:apache][:serve_local_files]="true"
# List of required apache modules
set[:app][:module_dependencies] = ["proxy", "proxy_http"]


# Defining apache user, group and log directory path depending on platform.
case node[:platform]
  when "ubuntu","debian"
    set[:app_django][:apache][:log_dir]="/var/log/apache2"
  when "centos","redhat","redhatenterpriseserver","fedora","suse"
    set[:app_django][:apache][:log_dir]="/var/log/httpd"
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Path to PIP executable
set[:app_django][:pip_bin]="/usr/bin/pip-python"
# Path to python executable
set[:app_django][:python_bin]="/usr/bin/python"
# List of additional python packages, required for django application
set_unless[:app_django][:project][:opt_pip_list]=""
# List of python commands required for django application initialization
set_unless[:app_django][:project][:custom_cmd]=""
# Django application debug mode
set_unless[:app_django][:debug_mode]="False"
