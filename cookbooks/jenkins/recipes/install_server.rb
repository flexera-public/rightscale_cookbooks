#
# Cookbook Name:: jenkins
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Create the home directory for Jenkins.
directory node[:jenkins][:server][:home] do
  mode 0755
  recursive true
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
end

# Create Jenkins private key file
file "#{node[:jenkins][:private_key_file]}" do
  content node[:jenkins][:private_key]
  mode 0600
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  action :create
end

# Jenkins package installation based on platform
case node[:platform]
when "centos"
  # Add Jenkins repo
  remote_file "/etc/yum.repos.d/jenkins.repo" do
    source "http://pkg.jenkins-ci.org/redhat/jenkins.repo"
  end

  # Import Jenkins RPM key
  execute "import jenkins key" do
    command "rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
  end

  package "java-1.6.0-openjdk"

  # If a version is specified, include the release information. This is only
  # required for CentOS. The release appears to be the same for all Jenkins
  # versions available.
  node[:jenkins][:server][:version] += "-1.1" \
    if node[:jenkins][:server][:version]
  # Install Jenkins package
  package "jenkins" do
    version node[:jenkins][:server][:version]
  end

when "ubuntu"
  # Download the deb package file for the specified version
  remote_file "/tmp/jenkins_#{node[:jenkins][:server][:version]}_all.deb" do
    source "http://pkg.jenkins-ci.org/debian/binary/" +
      "jenkins_#{node[:jenkins][:server][:version]}_all.deb"
  end

  # dpkg doesn't resolve and install all dependencies and some of the packages
  # that jenkins depends are virtual packages provided by some other packages.
  # So Install all the dependencies before attempting to install jenkins deb
  # package. This complex setup is only required to install a specific version
  # of jenkins as the latest version might break the existing monkey
  # configuration.
  jenkins_dependencies = [
    "daemon",
    "adduser",
    "psmisc",
    "openjdk-6-jre"
  ]

  jenkins_dependencies.each do |pkg|
    package pkg
  end

  # Install Jenkins from the downloaded deb file
  dpkg_package "jenkins" do
    source "/tmp/jenkins_#{node[:jenkins][:server][:version]}_all.deb"
    action :install
  end

end

service "jenkins" do
  action :stop
end

# Change the jenkins user to root. Virtualmonkey doesn't allow running jenkins
# jobs as jenkins user or any other regular user. So jenkins should run as
# root. The following ticket is filed with virtualmonkey
# https://wush.net/trac/rightscale/ticket/5651
# Once this ticket is fixed, a new 'monkey' group can be created and any user
# belonging to that group will be allowed to run monkey tests.
jenkins_system_config_file = value_for_platform(
  "ubuntu" => {
    "default" => "/etc/default/jenkins"
  },
  "default" => "/etc/sysconfig/jenkins"
)

template jenkins_system_config_file do
  source "jenkins_system_config.erb"
  cookbook "jenkins"
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  mode 0644
  variables(
    :jenkins_home => node[:jenkins][:server][:home],
    :jenkins_user => node[:jenkins][:server][:system_user],
    :jenkins_port => node[:jenkins][:server][:port]
  )
end

# Make sure the permission for jenkins log directory set correctly
directory "/var/log/jenkins" do
  mode 0750
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
end

# Create the Jenkins user directory
directory "#{node[:jenkins][:server][:home]}/users/" +
  "#{node[:jenkins][:server][:user_name]}" do
  recursive true
  mode 0755
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
end

# Create the Jenkins configuration file to include matrix based security
template "#{node[:jenkins][:server][:home]}/config.xml" do
  source "jenkins_config.xml.erb"
  mode 0644
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  variables(
    :user => node[:jenkins][:server][:user_name]
  )
end


# Obtain the hash of the password.
chef_gem "bcrypt-ruby"

require "bcrypt"
node[:jenkins][:server][:password_encrypted] = ::BCrypt::Password.create(
  node[:jenkins][:server][:password]
)

# Create Jenkins user configuration file.
template "#{node[:jenkins][:server][:home]}/users/" +
  "#{node[:jenkins][:server][:user_name]}/config.xml" do
  source "jenkins_user_config.xml.erb"
  mode 0644
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  variables(
    :user_full_name => node[:jenkins][:server][:user_full_name],
    :password_encrypted => node[:jenkins][:server][:password_encrypted],
    :email => node[:jenkins][:server][:user_email]
  )
end

service "jenkins" do
  action :start
end

# Open Jenkins server port
sys_firewall "8080"

right_link_tag "jenkins:active=true"
right_link_tag "jenkins:master=true"
right_link_tag "jenkins:listen_ip=#{node[:jenkins][:ip]}"
right_link_tag "jenkins:listen_port=#{node[:jenkins][:server][:port]}"
