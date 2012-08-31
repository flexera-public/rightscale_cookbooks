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
ruby_block "db backup info file" do
  block do

    # File path
    info_file = "/mnt/storage/db_sys_info.log"

    # Create new file and write a header
    `echo '# Managed by RightScale\n# DO NOT EDIT BY HAND\n#' > #{info_file}`

    # Array of bash commands the outputs of which will be written to the info file
    commands = [
      "uname -a",
      "lsb_release -a",
      "mysql -V",
      "df -k",
      "cat /etc/mysql/conf.d/my.cnf",
      "cat /etc/rightscale.d/*",
      "export",
      "gem list"
    ]

    # Array of values
    nodes = [
      "node[:virtualization][:system]"
    ]

    ::File.open(info_file, 'a') do |file|
      # Run commands and append the output with a separator to the info file
      commands.each do |command|
        # Write separator
        file.puts "\n\n" + "*" * 80 + "\n" + " " * ((80 - command.length) / 2) + command + "\n" + "*" * 80 + "\n"
        # Write command output
        file.puts `#{command} 2>&1`
      end
      # Get values and append them
      file.puts "\n\n" + ("*" * 80 + "\n") * 2
      nodes.each do |value|
        file.puts "#{value} == " + eval("#{value}").to_s
      end
    end

  end
end

rightscale_marker :end
