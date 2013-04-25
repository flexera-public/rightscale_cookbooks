# Include helper objects and methods.
require_helper "errors"
require_helper "monitoring"
require_helper "os"
require_helper "input"

# Test specific helpers.
#
helpers do

  # Missing log entries error.
  #
  class MissingLogMessageError < VirtualMonkey::TestCase::ErrorBase
  end

  # Gets the array of Logging servers in the deployment.
  #
  # @return [Array] an Array of ServerInterfaces of Logging servers
  #
  # @raise [SelectSetError] if no Logging servers found
  #
  def logging_servers
    result = select_set(/Logging/)
    raise SelectSetError, "No Logging servers found." unless result.length > 0
    result
  end

  # Gets the array of Base servers in the deployment.
  #
  # @return [Array] an Array of ServerInterfaces of Base servers
  #
  # @raise [SelectSetError] if no Base servers found
  #
  def base_servers
    result = select_set(/Base/)
    raise SelectSetError, "No Base servers found." unless result.length > 0
    result
  end

  # Gets the IP of the Logging server in the deployment.
  #
  # @return [String] the Logging server IP
  #
  def logging_ip(server)
    ip = server.private_ip
    ip = server.reachable_ip unless ip
    ip
  end

  # Tests whether the Logging server receives the clients log messages.
  #
  # @param server [ServerInterface] the client server
  # @param logging_server [ServerInterface] the Logging server
  #
  def check_remote_logging(server, logging_server)
    # Generating test string to pass from client to server.
    test_string = "Checking remote logging: #{server.reachable_ip} "
    test_string << rand(32**32).to_s(32)

    # Creates a log message with the test string on the client server.
    probe(server, "logger \"#{test_string}\"") do |result, status|
      unless status == 0
        raise FailedProbeCommandError, "Failed to create log message: #{result}"
      end
      true
    end

    # Sets server log file path depending on the OS.
    log_file_path =
      case get_operating_system(logging_server)
      when /ubuntu.*12/i
        "/var/log/syslog"
      else
        "/var/log/messages"
      end

    require "timeout"
    begin
      Timeout::timeout(300) do
        while true
          result = ""

          # Checks whether the log with the test string is on the
          # Logging server.
          probe(logging_server, "grep \"#{test_string}\" #{log_file_path}") do
          |responce, status|
            unless status == 0
              raise FailedProbeCommandError, "Probe error: #{responce}"
            end
            result = responce
            true
          end

          if result.empty?
            # Sleeping: time is needed for the log message to leave the client
            # server, be sent to the logging server, get processed and added to
            # the log file of the server.
            sleep(10)
          else
            puts "Log message \"#{test_string}\" found on the Logging server"
            break
          end
        end
      end
    rescue Timeout::Error
      raise TimeoutError, "ERROR: Timeout while looking for log message."
    end
  end

end

# Before tests that require UDP protocol.
#
before "smoke_test" do
  # Assumes there is a single Logging server in the deployment and a single
  # client Base server in the deployment.
  logging_server = logging_servers.first

  ensure_input_setting(
    logging_server,
    [{:name => "logging/protocol", :value => "text:udp"}]
  )
  ensure_input_setting(
    base_servers.first,
    [
      {:name => "logging/protocol", :value => "text:udp"},
      {:name => "logging/remote_server", :value => logging_ip(logging_server)}
    ]
  )
  check_monitoring(logging_server)
end

# The 'smoke_test' test_case for the Logging with rsyslog ServerTemplate ensures
# that the basic UDP logging functionality is working correctly.
#
test_case "smoke_test" do
  check_remote_logging(base_servers.first, logging_servers.first)
end

# Before tests that require RELP protocol.
#
before "relp" do
  logging_server = logging_servers.first

  ensure_input_setting(
    logging_server,
    [{:name => "logging/protocol", :value => "text:relp"}]
  )
  ensure_input_setting(
    base_servers.first,
    [
      {:name => "logging/protocol", :value => "text:relp"},
      {:name => "logging/remote_server", :value => logging_ip(logging_server)}
    ]
  )
  check_monitoring(logging_server)
end

# The 'relp' test_case for the Logging with rsyslog ServerTemplate ensures that
# the remote logging functionality over the RELP protocol is working correctly.
#
test_case "relp" do
  check_remote_logging(base_servers.first, logging_servers.first)
end

# Before tests that require RELP protocol with SSL encryption.
#
before "relp-secured" do
  logging_server = logging_servers.first

  ensure_input_setting(
    logging_server,
    [
      {:name => "logging/protocol", :value => "text:relp-secured"},
      {:name => "logging/certificate", :value => "cred:LOGGING_SSL_CRED"}
    ]
  )
  ensure_input_setting(
    base_servers.first,
    [
      {:name => "logging/protocol", :value => "text:relp-secured"},
      {:name => "logging/certificate", :value => "cred:LOGGING_SSL_CRED"},
      {:name => "logging/remote_server", :value => logging_ip(logging_server)}
    ]
  )
  check_monitoring(logging_server)
end

# The 'relp-secured' test_case for the Logging with rsyslog ServerTemplate
# ensures that the remote logging functionality over the RELP protocol with SSL
# encryption is working correctly.
#
test_case "relp-secured" do
  check_remote_logging(base_servers.first, logging_servers.first)
end
