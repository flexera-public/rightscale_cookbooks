#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

if "#{node[:rightscale][:security_update]}" == "Enabled"

  log "  Enabling security updates."
  case node[:platform]
  when "ubuntu"
    bash "Unfreeze Ubuntu security repositories" do
      flags "-ex"
      code <<-EOH
        # This is the Red teams bash script
        # Set all security repos to latest
        sed -i "s%ubuntu_daily/.* $(lsb_release -cs)-security%ubuntu_daily/latest $(lsb_release -cs)-security%" /etc/apt/sources.list.d/rightscale.sources.list

        # Update the local package index
        # Make sure we DON'T check the output of this, as apt-get update
        # may return a non-zero error code when one server is down but all
        # the others are up, and a partial update was successful!
        apt-get update || true
      EOH
    end
  when "centos", "redhat"
    # Set all repos to latest
    files = Dir.glob("/etc/yum.repos.d/*")

    repo_regex = /\/archive\/20[0-9]{6}$/
    latest = "/archive/latest"

    files.each do |file_name|
      text = File.read(file_name)
      replace = text.gsub!(repo_regex, latest)
      File.open(file_name, "w") { |file| file.puts replace }
    end

    # Update packages
    bash "Yum security updates" do
      flags "-ex"
      code <<-EOH
        # Assume we want to ignore output for the same reason as apt-get update
        yum --security update || true
      EOH
    end
  end

else

  log "  Security updates disabled.  Skipping setup!"

end

rightscale_marker :end
