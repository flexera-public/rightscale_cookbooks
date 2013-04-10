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
  execute "add jenkins repo" do
    command "wget -O /etc/yum.repos.d/jenkins.repo" +
      " http://pkg.jenkins-ci.org/redhat/jenkins.repo"
  end

  # Import Jenkins RPM key
  execute "import jenkins key" do
    command "rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key"
  end

  # Install Jenkins package
  package "jenkins" do
    version node[:jenkins][:server][:version]
  end

  package "java-1.6.0-openjdk"
when "ubuntu"
  # Import Jenkins key
  execute "import jenkins key" do
    command "wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -"
  end

  node[:jenkins][:apt_repo] = "deb http://pkg.jenkins-ci.org/debian binary/"
  # Add Jenkins repo to repo list
  execute "add jenkins repo" do
    command "echo #{node[:jenkins][:apt_repo]} >> /etc/apt/sources.list"
    not_if { File.open("/etc/apt/sources.list").lines.any? { |line| line.chomp == node[:jenkins][:apt_repo] }
  end

  package "jenkins" do
    version node[:jenkins][:server][:version]
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
    node[:jenkins][:server][:password_encrypted] = ::BCrypt::Password.create(
      node[:jenkins][:server][:password]
    )
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

service "jenkins" do
  action :start
end

# Open Jenkins server port
sys_firewall "8080"

right_link_tag "jenkins:active=true"
right_link_tag "jenkins:master=true"
right_link_tag "jenkins:listen_ip=#{node[:jenkins][:ip]}"
right_link_tag "jenkins:listen_port=#{node[:jenkins][:server][:port]}"
