#
# Cookbook Name:: app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.


# Setting Django version
set[:app_django][:version] = "1.4"

# Recommended attributes
set_unless[:app_django][:app][:static_dir] = "static"

# Django application debug mode - https://docs.djangoproject.com/en/dev/ref/settings/#debug
set_unless[:app_django][:app][:debug_mode] = "False"

# By default django uses MySQL as the DB adapter
set_unless[:app][:db_adapter] = "mysql"
# By default apache will serve any existing local files directly (except actionable ones)
set_unless[:app_django][:apache][:serve_local_files] = "true"
# List of required apache modules
set[:app][:module_dependencies] = ["proxy", "proxy_http"]


# Defining apache user, group and log directory path depending on platform.
case node[:platform]
  when "ubuntu"
    set[:app_django][:apache][:log_dir] = "/var/log/apache2"
  when "centos"
    set[:app_django][:apache][:log_dir] = "/var/log/httpd"
  else
    raise "Unrecognized distro #{node[:platform]}, exiting "
end

# Path to PIP executable
set[:app_django][:pip_bin] = "/usr/bin/pip"
# Path to python executable
set[:app_django][:python_bin] = "/usr/bin/python"
# List of additional python packages, required for django application
set_unless[:app_django][:project][:opt_pip_list] = ""
# List of python commands required for django application initialization
set_unless[:app_django][:project][:custom_cmd] = ""
