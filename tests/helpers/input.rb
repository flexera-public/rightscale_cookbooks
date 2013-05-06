# Verify the server is running with the correct inputs.
#
# If the inputs are correct return true - no relaunch is required.
# If the inputs are incorrect set them and return false indicating
# the server requires (re)launch.
#
# @param server [ServerInterface] the server to obtain value from
# @param inputs [Hash] representing inputs to be ensured to be set on the server
#
# @return [Boolean] true if the server is in the correct state.  False
#   if the inputs are not in the correct state and the server requires
#   relaunch.
#
def verify_instance_input_settings?(server, inputs)
  correct_settings = true
  puts "  #{server.nickname} state: '#{server.state}'"

  if server.state == "stopped" || server.state == "inactive"
    inputs.each do |name, value|
      puts "  Setting '#{name}' input to '#{value}'"
      server.set_inputs(name => value)
    end
    correct_settings = false
  else
    inputs.each do |name, value|
      # Returns the current value for input name on the given the server.
      current_value = get_input_from_server(server)[name]
      puts "  Currently '#{name}' input is set to '#{current_value}'"

      if current_value != value
        correct_settings = false
        puts "  Setting '#{name}' input to '#{value}'"
        server.set_inputs(name => value)
      end
    end
  end

  correct_settings
end
