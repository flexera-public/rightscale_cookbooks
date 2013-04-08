#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

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

r = rightscale_server_collection "master_server" do
  tags "jenkins:master=true"
  secondary_tags "jenkins:active=true"
  action :nothing
end
r.run_action(:load)

master_ip = ""
master_port = ""

r = ruby_block "find master" do
  block do
    node[:server_collection]["master_server"].each do |id, tags|
      master_ip_tag = tags.detect { |u| u =~ /jenkins:listen_ip/ } #.split(/=/, 2).last.chomp
      master_port_tag = tags.detect { |u| u =~ /jenkins:listen_port/ } #.split(/=/, 2).last.chomp
      master_ip = master_ip_tag.split(/=/, 2).last.chomp
      master_port = master_port_tag.split(/=/, 2).last.chomp

      Chef::Log.info "Master IP: #{master_ip}"
      Chef::Log.info "Master Port: #{master_port}"
    end
  end
end

r.run_action(:create)

ruby_block "Attach slave using Jenkins api" do
  block do
    if node[:jenkins][:slave][:attach_status] == :attached
      log "  Already attached to Jenkins master."
    else
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
      node[:jenkins][:slave][:attach_status] = :attached
    end
  end
  action :nothing
end

right_link_tag "jenkins:slave=true"
right_link_tag "jenkins:slave_name=#{node[:jenkins][:slave][:name]}"
right_link_tag "jenkins:slave_mode=#{node[:jenkins][:slave][:mode]}"
right_link_tag "jenkins:slave_ip=#{node[:jenkins][:ip]}"

rightscale_marker :end
