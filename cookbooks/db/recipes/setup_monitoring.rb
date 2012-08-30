#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

db node[:db][:data_dir] do
  action :setup_monitoring
end

# Creating a db backup info file
info_file = "/mnt/storage/db_sys_info.log"

file info_file do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

bash "write system and mysql information" do
  flags "-ex"
  code <<-EOH
    echo \"# Managed by RightScale\n# DO NOT EDIT BY HAND\n#\n\nSystem information:\" > "#{info_file}"
    uname -a >> "#{info_file}"
    lsb_release -a >> "#{info_file}" 2>&1
    echo \"\nMySQL information:\" >> "#{info_file}"
    mysql -V >> "#{info_file}"
  EOH
end

ruby_block "append hypervisor information" do
  block do
    open(info_file, 'a') { |file|  file.puts "\nHypervisor is #{node[:virtualization][:system]}" }
  end
end

rightscale_marker :end
