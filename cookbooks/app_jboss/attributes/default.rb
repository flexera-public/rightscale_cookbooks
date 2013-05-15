#
# Cookbook Name:: app_jboss
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Set Jboss install dir and version
set[:app_jboss][:install_target] = "/usr/share/jboss"

# List of required apache modules
set[:app_jboss][:module_dependencies] = [
  "proxy",
  "proxy_http",
  "deflate",
  "rewrite"
]

# Recommended attributes
default[:app_jboss][:code][:root_war] = ""
# Defines the initial value of the permanent generation space size
default[:app_jboss][:java][:permsize] = "256m"
# Defines the maximum value of the permanent generation space size
default[:app_jboss][:java][:maxpermsize] = "512m"
# Defines the initial size of new space generation
default[:app_jboss][:java][:newsize] = "448m"
# Defines the maximum size of new space generation
default[:app_jboss][:java][:maxnewsize] = "448m"
# Defines the maximum size of the heap used by the JVM
default[:app_jboss][:java][:xmx] = "1024m"
# Defines the initial size of the heap used by the JVM
default[:app_jboss][:java][:xms] = "1024m"
# Defines the survivor ratio used by the JVM
default[:app_jboss][:java][:survivor_ratio] = "6"

# Internal port for JBoss
default[:app_jboss][:internal_port] = "8080"

# Defining java alternatives command depending on platform.
case node[:platform]
when "ubuntu"
  set[:app_jboss][:alternatives_cmd] = "update-alternatives --auto java"
when "centos", "redhat"
  set[:app_jboss][:alternatives_cmd] = "alternatives --auto java"
else
  raise "Unrecognized distro #{node[:platform]}, exiting "
end
