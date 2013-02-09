
case node[:platform]
when "centos"
  yum_package "java-1.6.0-openjdk"
end

chef_gem "jenkins_api_client"

require "jenkins_api_client"

testpub = Mixlib::ShellOut.new("wget -O ~/testkey.pub http://dl.dropbox.com/u/1428622/RightScale/jenkins/testkey.pub")
  testpub.run_command

testcat = Mixlib::ShellOut.new("cat ~/testkey.pub >> ~/.ssh/authorized_keys")
  testcat.run_command

client = JenkinsApi::Client.new(
  :server_ip => master_ip,
  :server_port => master_port,
  :username => node[:jenkins][:server][:user_name],
  :password => node[:jenkins][:server][:password]
)

client.node.create_dump_slave(
  :name => node[:jenkins][:slave][:name],
  :slave_host => node[:jenkins][:ip],
  :private_key_file => node[:jenkins][:slave][:private_key_file],
  :executors => node[:jenkins][:slave][:executors]
)