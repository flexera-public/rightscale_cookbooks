#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Create the jenkins system user.
user node[:jenkins][:server][:system_user] do
  home node[:jenkins][:server][:home]
end

# Create the home directory for Jenkins.
directory node[:jenkins][:server][:home] do
  mode 0755
  recursive true
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
end

##Jenkins package installation.
case node[:platform]
when "centos"
  wrpm = Mixlib::ShellOut.new("wget -O ~/jenkins.rpm #{node[:jenkins][:mirror]}/latest/redhat/jenkins.rpm")
  wrpm.run_command

  jeninstall = Mixlib::ShellOut.new("rpm -i ~/jenkins.rpm")
  jeninstall.run_command

  testkey = Mixlib::ShellOut.new("wget -O /root/.ssh/api_user_key http://dl.dropbox.com/u/1428622/RightScale/jenkins/testkey")
  testkey.run_command

  # BROKEN: jenkins repo: https://www.google.com/#q=%22Error:+Cannot+retrieve+repository+metadata+(repomd.xml)+for+repository%22+%22jenkins%22
  #
  # #see http://jenkins-ci.org/redhat/
  # yum_key "jenkins_key" do
  #   url "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
  #   action :add
  # end

  # wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
  # yum_repository "jenkins" do
  #   repo_name "Jenkins"
  #   description "Jenkins Stable repo"
  #   url "http://pkg.jenkins-ci.org/redhat/jenkins.repo"
  #   key "jenkins-ci.org.key"
  #   action :add
  # end
  # yum_package "jenkins"

  # yum install jenkins -y

  yum_package "java-1.6.0-openjdk"

when "ubuntu"
  # See http://jenkins-ci.org/debian/
  apt_repository "jenkins" do
    uri "http://pkg.jenkins-ci.org/debian"
    distribution "binary/"
    components [""]
    key "http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key"
    action :add
  end

  apt_package "jenkins" do
    action :install
  end
end

service "jenkins" do
  action :stop
end

# Create the Jenkins user directory
directory "#{node[:jenkins][:server][:home]}/users/#{node[:jenkins][:server][:user_name]}" do
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

r = ruby_block "Encrypt Jenkins user password" do
  block do
    require "bcrypt"
    node[:jenkins][:server][:password_encrypted] = ::BCrypt::Password.create(node[:jenkins][:server][:password])
  end
  action :nothing
end
r.run_action(:create)

# Create Jenkins user configuration file.
template "#{node[:jenkins][:server][:home]}/users/#{node[:jenkins][:server][:user_name]}/config.xml" do
  source "jenkins_user_config.xml.erb"
  mode 0644
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  variables({
    :user_full_name => node[:jenkins][:server][:user_full_name],
    :password_encrypted => node[:jenkins][:server][:password_encrypted],
    :email => node[:jenkins][:server][:user_email]
  })
end

include_recipe "jenkins::install_plugins"

service "jenkins" do
  action :start
end
