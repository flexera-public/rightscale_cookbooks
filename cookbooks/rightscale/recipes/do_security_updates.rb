#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if "#{node[:rightscale][:security_updates]}" == "enable"

  case node[:platform]
  when "ubuntu"
    bash "Apply Ubuntu security updates" do
      flags "-ex"
      code <<-EOH
        # Make sure we DON'T check the output of this, as apt-get update
        # may return a non-zero error code when one server is down but all
        # the others are up, and a partial update was successful!
        apt-get update || true
      EOH
    end
  end
    # Update packages
    bash "Yum security updates" do
      flags "-ex"
      code <<-EOH
        # Assume we want to ignore output for the same reason as apt-get update
        yum -y --security update || true
      EOH
    end

else

  log "  Security updates disabled.  Skipping update!"

end
