#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# == Only setup remote logging for ec2 clouds. The logic is in the syslog.conf template and
#    below for adding tags for lumberjack

rightscale_marker :begin

log "Configure syslog logging"

# == Make sure syslog-ng is installed.
#
package "syslog-ng"

service "syslog-ng" do
  supports :start => true, :stop => true, :restart => true
  action [ :enable ]
end

# == Create a new /dev/null for syslog-ng to use
#
execute "ensure_dev_null" do
  creates "/dev/null.syslog-ng"
  command "mknod /dev/null.syslog-ng c 1 3"
end

# == Configure syslog
#
template "/etc/syslog-ng/syslog-ng.conf" do
  source "syslog.erb"
  variables ({
    :apache_log_dir => (node[:platform] =~ /redhat|centos/) ? "httpd" : "apache2"
  })
  notifies :restart, resources(:service => "syslog-ng")
end

# == Ensure everything in /var/log is owned by root, not syslog.
#
Dir.glob("/var/log/*").each do |f|

  # After stop-start operations ephemeral volume is recreated
  # all symlinks in /var/log/ to /mnt became broken because of missing target.
  # At first we will check if this entry is a symlink and is it broken or not
  # and delete only broken ones
  link "#{f}" do
    action :delete
    only_if "test ! -e #{f} && test -L #{f}"
  end

  # ignore `ntpstats' directory because ntp user needs to write there
  next if f == "/var/log/ntpstats"

  # Changing owner for directories
  directory f do
    owner "root"
    only_if do File.directory?(f) end
    notifies :restart, resources(:service => "syslog-ng")
  end

  # Changing owner for files
  file f do
    owner "root"
    only_if do File.file?(f) end
    notifies :restart, resources(:service => "syslog-ng")
  end

end

# == Set up log file rotation
#
cookbook_file "/etc/logrotate.conf" do
  source "logrotate.conf"
  backup false
end

cookbook_file node[:rightscale][:logrotate_config] do
  source "logrotate.d.syslog"
  backup false
end

# == Fix /var/log/boot.log issue
#
file "/var/log/boot.log" 

# non-ec2 clouds will not have lumberjack remote logging feature for now.
#
if "#{node[:rightscale][:servers][:lumberjack][:hostname]}" != "" && node[:rightscale][:enable_remote_logging] == true

  log "Setting up 'REMOTE' syslog logging"

  # == Tag required to activate logging
  #
  right_link_tag "rs_logging:state=active"
  log "Setting logging active tag"
  
  rightscale_marker :end

end
