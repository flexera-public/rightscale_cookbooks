# Include helper objects and methods.
require_helper "errors"

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
# @param inputs [Hash] representing inputs to be ensured to be set on the server
#
def ensure_input_setting(server, inputs)
  puts "  #{server.nickname} state: '#{server.state}'"

  if server.state == "stopped" || server.state == "inactive"
    inputs.each do |name, value|
      puts "  Setting '#{name}' input to '#{value}'"
      server.set_inputs(name => value)
    end
    puts "  Launching #{server.nickname}"
    relaunch_server(server)
  else
    do_relaunch = false

    inputs.each do |name, value|
      # Returns the current value for input name on the given the server.
      current_value = get_input_from_server(server)[name]
      puts "  Currently '#{name}' input is set to '#{current_value}'"

      if current_value != value
        puts "  Setting '#{name}' input to '#{value}'"
        server.set_inputs(name => value)
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
