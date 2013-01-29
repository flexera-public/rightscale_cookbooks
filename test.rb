cloud = "test_cloud"
container = "test_container"
dumpfilepath = "/tmp/dump"
prefix = "kannan"

command = "/opt/rightscale/sandbox/bin/ros_util get --cloud #{cloud}" 
command << " container #{container} --dest #{dumpfilepath}"      
command << " --source #{prefix} --latest"

       puts command

puts "not nil"
  unless command.nil?
