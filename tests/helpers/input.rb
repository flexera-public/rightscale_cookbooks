# Include helper objects and methods.
require_helper "errors"

# Returns the current value for input name on the given the server.
#
# @param server [Server] the server to obtain value from
#
# @param input_name [String] the input name to obtain the value for
#
# @return [Array] Current setting [type, value]
#  type is one of "text", "cred", "env", key"
#
def get_server_input_value(server, input_name)
  result = get_input_from_server(server)
  result[input_name].split(":", 2)
end

# Ensure server is running with the correct setting for the
# input.
#
# If the server is stopped we can't (yet) get the current input
# so set the input to the desired state and launch all.
# If the server is not stopped then get the current input.
# If set to other than the desired state update the input to
# the desired state and relaunch all.
# If the server is running and the input is set to the desired
# state make no changes.
# In all cases wait til the servers are operational.
#
# @param server [Server] the server to obtain value from
#
# @param input_name [String].  The the name of the input
#
# @param input_type [String].  The the type of the input
#  "text", "cred", "env", and "key"
#
# @param desired_state [String].  The desired input setting
#
def ensure_input_setting(server, input_name, input_type, desired_setting)
  input_string = "#{input_type}:#{desired_setting}"
  state = server.state
  puts "  Current server state: #{state}"
  puts "  Input name: #{input_name}"
  puts "  Setting security updates input to #{input_string}"
  if state == "stopped" || state == "inactive"
    server.set_inputs(input_name => "#{input_string}")
    puts "  Servers in stopped state.  Launch all"
    launch_all
  else
    current_type, current_value = get_server_input_value(server, input_name)
    puts "  Current security updates input setting: #{current_type}:#{current_value}"
    if current_value != desired_setting
      puts "  Servers running with incorrect input setting."
      puts "  Update input and relaunch all"
      server.set_inputs(input_name => "#{input_string}")
      relaunch_all
    end
  end
  
  wait_for_all("operational")
end
