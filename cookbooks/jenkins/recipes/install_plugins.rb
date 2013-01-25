directory "#{node[:jenkins][:server][:home]}/plugins" do
  owner node[:jenkins][:server][:system_user]
  group node[:jenkins][:server][:system_group]
  only_if { node[:jenkins][:server][:plugins] }
end

unless node[:jenkins][:server][:plugins].empty?
  node[:jenkins][:server][:plugins_array] = node[:jenkins][:server][:plugins].split(" ")
end

node[:jenkins][:server][:plugins_array].each do |name|
  remote_file "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi" do
    source "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
    backup false
    owner node[:jenkins][:server][:system_user]
    group node[:jenkins][:server][:system_group]
    action :nothing
  end


  http_request "HEAD #{node[:jenkins][:mirror]}/latest/#{name}.hpi" do
    message ""
    url "#{node[:jenkins][:mirror]}/latest/#{name}.hpi"
    action :head
    if File.exists?("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi")
      headers "If-Modified-Since" => File.mtime("#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi").httpdate
    end
    notifies :create, resources(:remote_file => "#{node[:jenkins][:server][:home]}/plugins/#{name}.hpi"), :immediately
  end
end
