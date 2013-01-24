#
# Cookbook Name:: db
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

# Check for valid prefix / dump filename
dump_file_regex = '(^\w+)(-\d{1,12})*$'
raise "Prefix: #{node[:db][:dump][:prefix]} invalid.  It is restricted to word characters (letter, number, underscore) and an optional partial timestamp -YYYYMMDDHHMM.  (=~/#{dump_file_regex}/ is the ruby regex used). ex: myapp_prod_dump, myapp_prod_dump-201203080035 or myapp_prod_dump-201203" unless node[:db][:dump][:prefix] =~ /#{dump_file_regex}/ || node[:db][:dump][:prefix] == ""

# Check variables and log/skip if not set
skip, reason = true, "DB/Schema name not provided" if node[:db][:dump][:database_name] == ""
skip, reason = true, "Prefix not provided" if node[:db][:dump][:prefix] == ""
skip, reason = true, "Storage account provider not provided" if node[:db][:dump][:storage_account_provider] == ""
skip, reason = true, "Container not provided" if node[:db][:dump][:container] == ""

if skip
  log "  Skipping import: #{reason}"
else

  db_name = node[:db][:dump][:database_name]
  prefix = node[:db][:dump][:prefix]
  dumpfilepath_without_extension = "/tmp/" + prefix
  container = node[:db][:dump][:container]
  cloud = node[:db][:dump][:storage_account_provider]
  command_to_execute = "/opt/rightscale/sandbox/bin/ros_util get" +
    " --cloud #{cloud} --container #{container}" +
    " --dest #{dumpfilepath_without_extension}" +
    " --source #{prefix} --latest"

  # Obtain the dumpfile from ROS
  execute "Download dumpfile from Remote Object Store" do
    command command_to_execute
    creates dumpfilepath_without_extension
    environment ({
      'STORAGE_ACCOUNT_ID' => node[:db][:dump][:storage_account_id],
      'STORAGE_ACCOUNT_SECRET' => node[:db][:dump][:storage_account_secret]
    })
  end

  # Detect the compression type of the downloaded file and set the
  # extension properly.
  node[:db][:dump][:filepath] = ""
  node[:db][:dump][:uncompress_command] = ""
  ruby_block "Detect compression type" do
    block do
      require "fileutils"

      file_type = Chef::ShellOut.new("file #{dumpfilepath_without_extension}")
      file_type.run_command
      file_type.error!
      command_output = file_type.stdout

      extension = ""
      if command_output =~ /Zip archive data/
        extension = "zip"
        node[:db][:dump][:uncompress_command] = "unzip -p"
      elsif command_output =~ /gzip compressed data/
        extension = "gz"
        node[:db][:dump][:uncompress_command] = "gunzip <"
      elsif command_output =~ /bzip2 compressed data/
        extension = "bz2"
        node[:db][:dump][:uncompress_command] = "bunzip2 <"
      end
      node[:db][:dump][:filepath] = dumpfilepath_without_extension +
        "." +
        extension
      FileUtils.mv(dumpfilepath_without_extension, node[:db][:dump][:filepath])

      # The dumpfile attribute for the db resource's "restore_from_dump_file"
      # action is evaluated during compile time and when it converges the old
      # value (the one without the extension) is used. This ruby block runs in
      # converge phase which updates the value to be used for the dumpfile
      # attribute. The following code will update the db resource's dumpfile
      # attribute in converge time.
      restore_resource = run_context.resource_collection.find(
        :db => node[:db][:data_dir]
      )
      restore_resource.dumpfile node[:db][:dump][:filepath]
    end
  end


  # Restore the dump file to db
  # See cookbooks/db_<provider>/providers/default.rb for the
  # "restore_from_dump_file" action.
  db node[:db][:data_dir] do
    dumpfile node[:db][:dump][:filepath]
    db_name db_name
    action :restore_from_dump_file
  end

  # Delete the local file.
  ruby_block "Delete the local file" do
    block do
      require "fileutils"
      FileUtils.rm_f node[:db][:dump][:filepath]
    end
  end

end

rightscale_marker :end
