#
# Cookbook Name::app_django
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Installing python packages using requirement.txt
#
# If the checked application contains a requirement.txt, then we can install all
# the required python packages using "pip install" command.
#
log "  pip will install python packages from requirement.txt"
# Installing python packages from /requirement.txt if it exists
bash "Bundle python packages install" do
  flags "-ex"
  code <<-EOH
    pip install --requirement=#{node[:app][:destination]}/requirement.txt
  EOH
  only_if do File.exists?("#{node[:app][:destination]}/requirement.txt")  end
end

rightscale_marker :end
