# Include the helper objects and methods.
require_helper "cloud"
require_helper "ephemeral"
require_helper "wait_for_ip_repopulation"

# Test specific helpers.
#
helpers do
  # An error with swap file setup.
  #
  class SwapFileError < VirtualMonkey::TestCase::ErrorBase
  end

  # Checks if the swap file is set up.
  #
  # @param server [Server] the server to check
  #
  # @raise [SwapFileError] if the swap file is not set up
  #
  def check_swap_file(server)
    # Get location of swap file from ServerTemplate input.
    swapfile = get_input_from_server(server)["sys/swap_file"].split("text:")[1]

    # SSH to the server and see if the swap file path is in the swap devices
    # list.
    #
    probe(servers.first, "grep -c #{swapfile} /proc/swaps") do |result, status|
      puts "Swapfile: #{result.inspect}"
      raise SwapFileError, "raise swap file not setup correctly" unless ((result).to_i > 0)
      true
    end
  end

  # Checks if this test is running against a Chef ServerTemplate or an RSB
  # ServerTemplate.
  #
  # @return [Boolean] whether the test is running against a Chef ServerTemplate
  #
  def is_chef?
    suite_variables[:server_template_type] == "chef"
  end
end

# When rerunning a test, shutdown all of the servers.
#
hard_reset do
  stop_all
end

# Before all of the test cases, launch all of the servers in the deployment.
#
before do
  launch_all
  wait_for_all("operational")
end

# The Base smoke test makes sure the Base (Chef or RSB) ServerTemplate has its
# basic functionality including setting up any ephemeral volumes, setting up a
# swap file, and basic monitoring. It checks if this functionality is working
# after initial boot and then after a single reboot.
#
test_case "smoke_test" do
  # Get current cloud.
  cloud = Cloud.factory

  # Single server in deployment.
  server = servers.first

  # Ephemeral and swap file support are currently only implemented on the Chef
  # ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
  end

  # Check if the server's basic monitoring is working.
  check_monitoring

  # Reboot to check if functionality works after a reboot.
  reboot_all
  wait_for_all("operational")

  # Ephemeral and swap file support are currently only implemented on the Chef
  # ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
  end

  # Check if the server's basic monitoring is working.
  check_monitoring
end

# The Base stop/start test makes sure the Base (Chef or RSB) ServerTemplate has
# its basic functionality after a server has been stopped and then started
# again. The functionality it tests includes setting up any ephemeral volumes,
# setting up a swap file, and basic monitoring.
#
test_case "stop_start" do
  # Get the current cloud.
  cloud = Cloud.factory

  # Single server in deployment.
  server = servers.first

  # Only some clouds support stop/start.
  skip unless cloud.supports_stop_start?(server)

  # Stop server.
  puts "Stopping current server."
  server.stop_ebs
  wait_for_server_state(server, "stopped")

  # Start server.
  puts "Starting current server."
  server.start_ebs
  wait_for_server_state(server, "operational")
  # It takes about a minute for ips to get repopulated.
  wait_for_ip_repopulation(server)

  # Remove the public IP address tag if the cloud requires SSHing on the private
  # IP address.
  #
  server.remove_tags ["server:public_ip_0=#{server.public_ip}"] if cloud.needs_private_ssh?

  # Ephemeral and swap file support are currently only implemented on the Chef
  # ServerTemplate.
  #
  if is_chef?
    check_ephemeral_mount(server) if cloud.supports_ephemeral?(server)
    check_swap_file(server)
  end

  # Check if the server's basic monitoring is working.
  check_monitoring
end
