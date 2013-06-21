#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if "#{node[:rightscale][:security_updates]}" == "enable"

  platform =  node[:platform]
  log "  Applying secutiy updates for #{platform}"
  # Make sure we DON'T check the output of the update because it
  # may return a non-zero error code when one server is down but all
  # the others are up, and a partial update was successful!
  # If the upgrade fails then the security update monitor will
  # trigger alerting users to investigate what went wrong.
  case platform
  when "ubuntu"
    bash "Apply apt security updates" do
      flags "-ex"
      code <<-EOH
        apt-get update && apt-get upgrade || true
      EOH
    end
  when "centos", "redhat"
    # Update packages
    bash "Apply yum security updates" do
      flags "-ex"
      code <<-EOH
        yum -y --security update || true
      EOH
    end
  else
    log " Security updates not supported for platform #{platform}"
  end

else

  log "  Security updates disabled.  Skipping update!"

end
