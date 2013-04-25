# Include helper objects and methods.
require_helper "errors"

# Returns the current value for input name on the given the server.
#
# @param server [Server] the server to obtain value from
#
# @param input_name [String] the input name to obtain the value for
#
# @return [String] current input setting "input_type:input_value"
#
def get_server_input_value(server, input_name)
  result = get_input_from_server(server)
  result[input_name]
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
# @param inputs [Array] of Hashes in a format of
#   {:name => "input_name", :value => "input_type:input_value"}
#   representing inputs to be ensured to be set on the server
#
def ensure_input_setting(server, inputs)
  puts "  #{server.nickname} state: #{server.state}"

  if server.state == "stopped" || server.state == "inactive"
    inputs.each do |input|
      puts "  Setting #{input[:name]} input to #{input[:value]}."
      server.set_inputs(input[:name] => input[:value])
    end
    puts "  Launching #{server.nickname}"
    relaunch_server(server)
  else
    do_relaunch = false

    inputs.each do |input|
      current_value = get_server_input_value(server, input[:name])
      puts "  #{input[:name]} input is set to: #{current_value}"

      if current_value != input[:value]
        puts "  Setting #{input[:name]} input to #{input[:value]}."
        server.set_inputs(input[:name] => input[:value])
        do_relaunch = true
      end
    end

    if do_relaunch
      puts "  Relaunching #{server.nickname}"
      relaunch_server(server)
    end
  end

  wait_for_server_state(server, "operational")
end
