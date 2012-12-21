# suite variables: server_template_type = {chef, rsb}

# Include the helper objects and methods.
helper_include "cloud"
helper_include "wait_for_ip_repopulation"

helpers do
  # Checks if the swapfile is listed in /proc/swaps.
  #
  # @param server [Server] Server's swapspace to check.
  #
  # @return [Boolean] True if swapfile is listed.
  #
  # @raises [RuntimeError] If swap file cannot be setup.
  def test_swapspace(server)
    # Get location of swapfile from ServerTemplate input.
    swapfile = get_input_from_server(server)["sys/swap_file"].to_s.split("text:")[1]

    probe(servers.first, "grep -c #{swapfile} /proc/swaps") do |result, status|
      puts "Swapfile: #{result.inspect}"
      raise "raise swap file not setup correctly" unless ((result).to_i > 0)
      true
    end
  end

  # Checks the server template uses Chef.
  # Will be deprecated after features are ported to RSB.
  #
  # @return [Boolean] True if server template uses chef and False otherwise.
  def is_chef?
    suite_variables[:server_template_type] == "chef"
  end
end

hard_reset do
  stop_all
end

before do
  launch_all
  wait_for_all("operational")
end

test "smoke_test" do
  # Single server in deployment.
  server = servers.first

  if is_chef?
    verify_ephemeral_mounted
    test_swapspace(server)
  end

  check_monitoring

  reboot_all
  wait_for_all("operational")

  if is_chef?
    verify_ephemeral_mounted
    test_swapspace(server)
  end

  check_monitoring
end

test "ebs_stop_start" do
  # Current cloud.
  cloud = Cloud.factory

  # Single server in deployment.
  server = servers.first

  skip unless cloud.supports_start_stop?(server)

  # Stop EBS server.
  puts "Stopping current server."
  server.stop_ebs
  wait_for_server_state(server, "stopped")

  # Start EBS server.
  puts "Starting current server."
  server.start_ebs
  wait_for_server_state(server, "operational")
  # It takes about a minute for ips to get repopulated.
  wait_for_ip_repopulation(server)

  verify_ephemeral_mounted
  remove_public_ip_tags
  check_monitoring
end
