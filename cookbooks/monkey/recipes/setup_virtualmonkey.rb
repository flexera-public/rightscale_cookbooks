#
# Cookbook Name:: monkey
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

packages = value_for_platform(
  "centos" => {
    "default" => ["libxml2-devel", "libxslt-devel", "file"]
  },
  "ubuntu" => {
    "default" => ["libxml2-dev", "libxml-ruby", "libxslt1-dev", "libmagic-dev"]
  }
)

# Installing packages required by VirtualMonkey
log "  Installing packages required by VirtualMonkey"
packages.each do |pkg|
  package pkg
end

# Checking out VirtualMonkey repository
log "  Checking out VirtualMonkey repository from:" +
  " #{node[:monkey][:virtualmonkey][:monkey_repo_url]}"
git node[:monkey][:virtualmonkey_path] do
  repository node[:monkey][:virtualmonkey][:monkey_repo_url]
  reference node[:monkey][:virtualmonkey][:monkey_repo_branch]
  action :sync
end

# By default chef changes the checked out branch to a branch named 'deploy'
# locally. To make sure we can pull/push changes, let's checkout the correct
# branch again!
#
execute "git checkout" do
  cwd node[:monkey][:virtualmonkey_path]
  command "git checkout #{node[:monkey][:virtualmonkey][:monkey_repo_branch]}"
end

# Check out right_api_object project from the Github repository
log "  Checking out right_api_objects project from:" +
  " #{node[:monkey][:virtualmonkey][:right_api_objects_repo_url]}"
git "#{node[:monkey][:user_home]}/right_api_objects" do
  repository node[:monkey][:virtualmonkey][:right_api_objects_repo_url]
  reference node[:monkey][:virtualmonkey][:right_api_objects_repo_branch]
  action :sync
end

# Check out the correct branch for right_api_objects
execute "git checkout" do
  cwd "#{node[:monkey][:user_home]}/right_api_objects"
  command "git checkout" +
    " #{node[:monkey][:virtualmonkey][:right_api_objects_repo_branch]}"
end

# Install the dependencies of right_api_objects
execute "bundle install" do
  cwd "#{node[:monkey][:user_home]}/right_api_objects"
  command "bundle install"
end

# Install the right_api_objects gem
execute "rake install" do
  cwd "#{node[:monkey][:user_home]}/right_api_objects"
  command "rake install"
end

# Install Virtualmonkey dependencies
log "  Installing Virtualmonkey dependencies"
execute "bundle install" do
  cwd node[:monkey][:virtualmonkey_path]
  command "bundle install --no-color --system"
end

# Create the VirtualMonkey configuration file from template. Currently, this
# configuration file is not managed by Chef.
log "  Creating VirtualMonkey configuration file from template"
execute "copy virtualmonkey configuration file" do
  cwd node[:monkey][:virtualmonkey_path]
  command "cp config.yaml .config.yaml"
  not_if do
    ::File.exists?("#{node[:monkey][:virtualmonkey_path]}/.config.yaml")
  end
end

# Populate all virtualmonkey cloud variables
log "  Populating virtualmonkey cloud variables"
execute "populate cloud variables" do
  command "#{node[:monkey][:virtualmonkey_path]}/bin/monkey" +
    " populate_all_cloud_vars" +
    " --force" +
    " --overwrite" +
    " --yes"
end

###############################################################################
# The following code checks out the virtualmonkey nextgen code and sets it up
# so we don't have to launch different monkeys for testing the nextgen
# collateral. This code should be removed from the template when the TOS
# collateral is abondoned.
#
# Checking out VirtualMonkey repository
log "  Checking out VirtualMonkey repository from:" +
  " #{node[:monkey][:virtualmonkey][:monkey_repo_url]}"
git "#{node[:monkey][:virtualmonkey_path]}-ng" do
  repository node[:monkey][:virtualmonkey][:monkey_repo_url]
  reference "colrefactor"
  action :sync
end

# By default chef changes the checked out branch to a branch named 'deploy'
# locally. To make sure we can pull/push changes, let's checkout the correct
# branch again!
#
execute "git checkout" do
  cwd "#{node[:monkey][:virtualmonkey_path]}-ng"
  command "git checkout colrefactor"
end

# Install Virtualmonkey dependencies
log "  Installing Virtualmonkey dependencies"
execute "bundle install" do
  cwd "#{node[:monkey][:virtualmonkey_path]}-ng"
  command "bundle install --no-color --system"
end

# Create the VirtualMonkey configuration file from template. Currently, this
# configuration file is not managed by Chef.
log "  Creating VirtualMonkey configuration file from template"
execute "copy virtualmonkey configuration file" do
  cwd "#{node[:monkey][:virtualmonkey_path]}-ng"
  command "cp config.yaml .config.yaml"
  not_if do
    ::File.exists?("#{node[:monkey][:virtualmonkey_path]}-ng/.config.yaml")
  end
end

# Populate all virtualmonkey cloud variables
log "  Populating virtualmonkey cloud variables"
execute "populate cloud variables" do
  command "#{node[:monkey][:virtualmonkey_path]}-ng/bin/monkey" +
    " populate_all_cloud_vars" +
    " --force" +
    " --overwrite" +
    " --yes"
end

# Add virtualmonkey-ng to PATH
file "/etc/profile.d/01virtualmonkey-ng.sh" do
  owner "root"
  group "root"
  mode 0755
  content "export PATH=#{node[:monkey][:virtualmonkey_path]}-ng/bin:$PATH"
  action :create
end

# Checkout the nextgen collateral project and configure it
nextgen_collateral_name = "rightscale_cookbooks_private"
nextgen_collateral_repo_url =
  "git@github.com:rightscale/rightscale_cookbooks_private.git"

log "  Checking out nextgen collateral repo to" +
  " #{nextgen_collateral_name}"
git "#{node[:monkey][:user_home]}/#{nextgen_collateral_name}" do
  repository nextgen_collateral_repo_url
  reference node[:monkey][:virtualmonkey][:collateral_repo_branch]
  action :sync
end

execute "git checkout" do
  cwd "#{node[:monkey][:user_home]}/#{nextgen_collateral_name}"
  command "git checkout" +
    " #{node[:monkey][:virtualmonkey][:collateral_repo_branch]}"
end

log "  Installing gems required for the nextgen collateral project"
execute "bundle install on collateral" do
  cwd "#{node[:monkey][:user_home]}/#{nextgen_collateral_name}"
  command "bundle install --no-color --system"
end

###############################################################################

# Add virtualmonkey to PATH
file "/etc/profile.d/02virtualmonkey.sh" do
  owner "root"
  group "root"
  mode 0755
  content "export PATH=#{node[:monkey][:virtualmonkey_path]}/bin:$PATH"
  action :create
end

# Installing right_cloud_api gem from the template file found in rightscale
# cookbook. The rightscale::install_tools installs this gem in sandbox ruby
# and we want it in system ruby
#
log "  Installing the right_cloud_api gem"
gem_package "right_cloud_api" do
  gem_binary "/usr/bin/gem"
  source ::File.join(
    ::File.dirname(__FILE__),
    "..",
    "..",
    "rightscale",
    "files",
    "default",
    "right_cloud_api-#{node[:monkey][:right_cloud_api_version]}.gem"
  )
  action :install
end

log "  Obtaining collateral project name from repo URL"
basename_cmd = Mixlib::ShellOut.new("basename" +
  " #{node[:monkey][:virtualmonkey][:collateral_repo_url]} .git"
)
basename_cmd.run_command
basename_cmd.error!

node[:monkey][:virtualmonkey][:collateral_name] = basename_cmd.stdout.chomp

log "  Checking out collateral repo to" +
  " #{node[:monkey][:virtualmonkey][:collateral_name]}"
git "#{node[:monkey][:user_home]}/" +
  "#{node[:monkey][:virtualmonkey][:collateral_name]}" do
  repository node[:monkey][:virtualmonkey][:collateral_repo_url]
  reference node[:monkey][:virtualmonkey][:collateral_repo_branch]
  action :sync
end

execute "git checkout" do
  cwd "#{node[:monkey][:user_home]}/" +
    "#{node[:monkey][:virtualmonkey][:collateral_name]}"
  command "git checkout" +
    " #{node[:monkey][:virtualmonkey][:collateral_repo_branch]}"
end

log "  Installing gems required for the collateral project"
execute "bundle install on collateral" do
  cwd "#{node[:monkey][:user_home]}/" +
    "#{node[:monkey][:virtualmonkey][:collateral_name]}"
  command "bundle install --no-color --system"
end

log "  Updating the ServerTemplate IDs for old collateral"
execute "update_stids" do
  cwd "#{node[:monkey][:user_home]}/" +
    "#{node[:monkey][:virtualmonkey][:collateral_name]}"
  command "bin/update_stids --source linux --lineage" +
    " #{node[:monkey][:virtualmonkey][:collateral_repo_branch]}.csv"
  only_if do
    File.exists?(
      "#{node[:monkey][:user_home]}/" +
      "#{node[:monkey][:virtualmonkey][:collateral_name]}/" +
      "csv_sheets/" +
      "#{node[:monkey][:virtualmonkey][:collateral_repo_branch]}.csv"
    )
  end
end

# Install the jsonlint tool for checking if the JSON file is valid
cookbook_file "/usr/bin/jsonlint" do
  source "jsonlint"
  mode 0755
end

# Create the directory for virtualmonkey log files
directory "/var/log/virtualmonkey" do
  owner node[:monkey][:user]
  group node[:monkey][:group]
  recursive true
end

# Setup Windows related ruby environment and gems. Since the "winrm" gem used
# for connecting to windows machines requires Ruby 1.9.1 and only Ubuntu
# supports the installation of Ruby 1.9.1, the following setup will only be
# fone on Ubuntu images.
if node[:platform] =~ /ubuntu/
  log "  Setting up Ruby 1.9 on Ubuntu"
  version = Mixlib::ShellOut.new("ruby --version")
  version.run_command.error!
  # Install Ruby 1.9.1 if it is not already installed
  if version.stdout =~ /1\.9/
    log "  Ruby #{version.stdout} is already installed on this system."
  else
    # Installs ruby 1.9 with rubygems.
    ["ruby1.9.1-full", "rubygems"].each do |pkg|
      package pkg
    end
  end

  # Install the required gems for windows
  gems = {"winrm" => "1.1.2", "trollop" => "2.0"}
  gems.each do |gem_name, gem_version|
    gem_package gem_name do
      gem_binary "/usr/bin/gem1.9.1"
      version gem_version
    end
  end

  directory "#{node[:monkey][:user_home]}/.virtualmonkey" do
    owner node[:monkey][:user]
    group node[:monkey][:group]
  end

  file "#{node[:monkey][:user_home]}/.virtualmonkey/windows_password" do
    content node[:monkey][:virtualmonkey][:windows_admin_password]
    owner node[:monkey][:user]
    group node[:monkey][:group]
    mode 0600
  end
else
  log "  Not a ubuntu server. Setup for windows testing is skipped."
end
