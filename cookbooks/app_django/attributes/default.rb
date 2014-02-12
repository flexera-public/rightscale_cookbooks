#
# Cookbook Name:: app_django
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# List of required apache modules
default[:app_django][:module_dependencies] = []
# By default apache will serve any existing local files directly (except actionable ones)
default[:app_django][:apache][:serve_local_files] = "true"
# Setting Django version
set[:app_django][:version] = "1.4"
# Path to PIP executable
set[:app_django][:pip_bin] = "/usr/bin/pip"
# Path to python executable
set[:app_django][:python_bin] = "/usr/bin/python"

# Recommended attributes

# Django application debug mode
# https://docs.djangoproject.com/en/dev/ref/settings/#debug
default[:app_django][:app][:debug_mode] = "False"
# By default apache will serve any existing local files directly
# (except actionable ones)
default[:app_django][:apache][:serve_local_files] = "true"
# List of additional python packages, required for django application
default[:app_django][:project][:opt_pip_list] = ""
# List of python commands required for django application initialization
default[:app_django][:project][:custom_cmd] = ""
