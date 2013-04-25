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

# Ensure server is running with the correct setting for the input.
#
# If the server is stopped we can't (yet) get the current input so set the input
# to the desired state and launch all.
# If the server is not stopped then get the current input.
# If set to other than the desired state update the input to the desired state
# and relaunch all.
# If the server is running and the input is set to the desired state make
# no changes.
# In all cases wait til the servers are operational.
#
# @param server [ServerInterface] the server to obtain value from
# @param input_name [String] the the name of the input
# @param input_type [String] the the type of the input "text", "cred", "env",
#   and "key"
# @param desired_value [String] the desired input setting
#
def ensure_input_setting(server, input_name, input_type, desired_value)
  input_string = "#{input_type}:#{desired_value}"

  puts "  #{server.nickname} state: #{server.state}"
  if server.state == "stopped" || server.state == "inactive"
    puts "  Setting #{input_name} input to #{input_string} and launching."
    server.set_inputs(input_name => "#{input_string}")
    relaunch_server(server)
  else
    current_type, current_value = get_server_input_value(server, input_name)
    puts "  #{input_name} input is set to: #{current_type}:#{current_value}"

    if current_value != desired_value
      puts "  Setting #{input_name} input to #{input_string} and relaunching."
      server.set_inputs(input_name => "#{input_string}")
      relaunch_server(server)
    end
  end

  wait_for_server_state(server, "operational")
end
