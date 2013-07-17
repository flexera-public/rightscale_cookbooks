#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if "#{node[:rightscale][:security_updates]}" == "enable"
  log "  Enabling security updates."
  case node[:platform]
  when "ubuntu"
    # Set all Ubuntu security repos to latest
    execute "unfreeze ubuntu security repositories" do
      command "sed -i \"s%ubuntu_daily/.* $(lsb_release -cs)-security%ubuntu_daily/latest $(lsb_release -cs)-security%\" /etc/apt/sources.list.d/rightscale.sources.list"
    end
    # Update the repositories initially to get the latest security updates
    execute "apt-get update" do
      command "apt-get update -y"
    end
  when "centos"
    ruby_block "Unfreeze CentOS repositories" do
      block do
        # Set all repos to latest
        files = Dir.glob("/etc/yum.repos.d/*.repo")

        repo_regex = /\/archive\/20[0-9]{6}$/
        latest = "/archive/latest"

        files.each do |file_name|
          # Skip non-upstream repositories
          next if file_name =~ /RightScale/
          text = File.read(file_name)
          text.gsub!(repo_regex, latest)
          File.open(file_name, "w") { |file| file.puts text }
        end
      end
    end
    # Update local cache for security updates
    execute "yum makecache -y" do
      command "yum makecache -y"
    end
  end
else
  log "  Security updates disabled.  Skipping setup!"
end
