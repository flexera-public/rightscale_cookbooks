#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

if node[:rightscale][:security_updates] == "enable"
  log "  Enabling security updates."
  case node[:platform]
  when "ubuntu"
    # Sets all Ubuntu security repos to latest
    unfreeze_ubuntu_repos = execute "unfreeze ubuntu security repositories" do
      command "sed -i \"s%ubuntu_daily/.* $(lsb_release -cs)-security%ubuntu_daily/latest $(lsb_release -cs)-security%\" /etc/apt/sources.list.d/rightscale.sources.list"
      action :nothing
    end
    unfreeze_ubuntu_repos.run_action(:run)

    # Updates the repositories initially to get the latest security updates.
    apt_get_update = execute "apt-get update --yes" do
      action :nothing
    end
    apt_get_update.run_action(:run)
  when "centos"
    unfreeze_centos_repos = ruby_block "unfreeze centos repositories" do
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
      action :nothing
    end
    unfreeze_centos_repos.run_action(:create)

    # Updates local cache for security updates.
    yum_makecache = execute "yum makecache --assumeyes" do
      action :nothing
    end
    yum_makecache.run_action(:run)

    # Adds a cron.daily script to update the yum cache.
    cookbook_file "/etc/cron.daily/yum-makecache.cron" do
      owner "root"
      group "root"
      mode 0755
      source "yum-makecache.cron"
    end
  else
    log "  Security updates are not supported for platform:" +
      " #{node[:platform]}. Skipping setup!"
  end
else
  log "  Security updates disabled. Skipping setup!"
end
