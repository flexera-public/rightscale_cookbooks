# Include helper objects and methods.
require_helper "errors"

# Include generic ruby libraries and gems.
require "timeout"

# Verifies the monitoring of the given plugin in the given server during the
# time period provided.
#
# @param server [Server] server to check the monitoring
# @param plugin_name [String] the name of the plugin to check
# @param plugin_type [String] the type of the plugin to check
# @param start_time [Fixnum] the start time to check
# @param end_time [Fixnum] the end time to check
#
# @raise [MonitoringError] monitoring for the specified plugin is not
#   functioning properly
#
def check_monitoring(server, plugin_name = "cpu-0", plugin_type = "cpu-idle",
                     start_time = -60, end_time = 20)
  puts "Checking monitoring for plugin name: #{plugin_name}" +
    " plugin type: #{plugin_type} with start time: #{start_time} and" +
    " with end time: #{end_time}"
  # Populates the settings for the server
  server.settings
  response = nil
  count = 0
  until response || count > 20 do
    begin
      response = server.monitoring
    rescue
      response = nil
      count += 1
      sleep 10
    end
  end
  unless response
    raise MonitoringError, "Failed to verify that monitoring is operational"
  end

  monitoring_verified = false
  monitoring_values = []
  Timeout::timeout(300) do
    until monitoring_verified
      monitor = server.get_sketchy_data(
        "start" => start_time,
        "end" => end_time,
        "plugin_name" => plugin_name,
        "plugin_type" => plugin_type
      )

      # The values array consists of data points of the specified monitoring
      # metric in the given time period. The values can be zero but not all
      # values in the array should be not a number.
      monitoring_values = monitor["data"]["value"]
      # Remove all non-zero values from the monitoring values array
      monitoring_values.reject! { |value| value.nan? }
      if monitoring_values.length > 0
        monitoring_verified = true
      else
        puts "Monitoring data is still not populated." +
          " Sleeping for 10 seconds and trying again..."
        sleep 10
      end
    end
    unless monitoring_values.length > 0
      raise MonitoringError, "No monitoring data is returned for" +
        " plugin name: '#{plugin_name}' and plugin type: '#{plugin_type}'"
    end
    puts "Monitoring is functional for plugin name: '#{plugin_name}'" +
      " plugin type: '#{plugin_type}' on '#{server.nickname}'"
  end
end
