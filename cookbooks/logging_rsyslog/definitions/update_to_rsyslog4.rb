#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Both CentOS and RedHat 5.8 have rsyslog v3.22 as the latest provided package
# the IUS repository carries rsyslog v4.8 for these operating systems.
# Update is needed to support RELP and have all the security updates of the new version.
# Because YUM cannot remove the rsyslog package without dependencies we use RPM to do that

define :update_to_rsyslog4 do

  package "rsyslog" do
    action :remove
    options "--nodeps"
    ignore_failure true
    provider Chef::Provider::Package::Rpm
  end

  package "rsyslog4"

end
