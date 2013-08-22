#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# These are not conditional assignments, but array joins.
node[:rightscale][:plugin_list_array] = node[:rightscale][:plugin_list].split | node[:rightscale][:plugin_list_array]
node[:rightscale][:process_list_array] = node[:rightscale][:process_list].split | node[:rightscale][:process_list_array]

# Install Attached Packages
#
# Installs collectd packages that are matched to the RightScale monitoring
# system.  These packages are locked/pinned to avoid accidental update.
#
package "librrd4" if node[:platform] == 'ubuntu'

installed_ver = (node[:platform] =~ /redhat|centos/) ? `rpm -q --queryformat %{VERSION} collectd`.strip : `dpkg-query --showformat='${Version}' -W collectd`.strip
installed = (installed_ver == "") ? false : true
log "  Collectd package not installed" unless installed
log "  Checking installed collectd version: installed #{installed_ver}" if installed

# Remove existing version of collectd
# Upgrade for rpm does not seem to work so using two step - removal and install.
package "collectd" do
  action :remove
end

# Install collectd packages
log "  Installing latest collectd package."

node[:rightscale][:collectd_packages].each do |pkg|
  if node[:platform] =~ /redhat|centos/
    # The EPEL repository contains both 64bit and 32bit packages:
    # using 'yum_package' resource to force the architecture of the package that
    # will be installed.
    yum_package pkg do
      arch "x86_64"
    end
  else
    package pkg
  end
end

# Enable service on system restart
service "collectd" do
  action :enable
end

# Generate config file
#
# This should be updated to use the default config file installed with the package.
# The default configs should be template-ized as needed.
template node[:rightscale][:collectd_config] do
  backup 5
  source "collectd.config.erb"
  notifies :restart, resources(:service => "collectd")
end

# Create plugin conf dir
directory "#{node[:rightscale][:collectd_plugin_dir]}" do
  owner "root"
  group "root"
  recursive true
  action :create
end

# Install a Nightly Crontask to Restart Collectd
#
# Add the task to /etc/crontab, at 04:00 localtime.
cron "collectd" do
  command "service collectd restart > /dev/null"
  minute "00"
  hour "4"
end

# Monitor Processes from Script Input
#
# Write the process file into the include directory from template.
template File.join(node[:rightscale][:collectd_plugin_dir], 'processes.conf') do
  backup false
  source "processes.conf.erb"
  notifies :restart, resources(:service => "collectd")
end

# Patch collectd init script, so it uses collectdmon.
# Only needed for CentOS, Ubuntu already does this out of the box.
if node[:platform] =~ /redhat|centos/
  cookbook_file "/etc/init.d/collectd" do
    source "collectd-init-centos-with-monitor"
    mode 0755
    notifies :restart, resources(:service => "collectd")
  end
end

# Tag required to enable monitoring
#
right_link_tag "rs_monitoring:state=active"

# Start monitoring
#
service "collectd" do
  action :start
end

log "  RightScale monitoring setup complete."

rightscale_marker :end
