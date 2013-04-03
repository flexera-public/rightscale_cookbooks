# Include the helper objects and methods.
require_helper "cloud"
require_helper "ephemeral"
require_helper "wait_for_ip_repopulation"
require_helper "errors"

# Test specific helpers.
#
helpers do
  # An error with swap file setup.
  #
  class SwapFileError < VirtualMonkey::TestCase::ErrorBase
  end

  # An error with conntrack_max setup
  #
  class ConntrackMaxError < VirtualMonkey::TestCase::ErrorBase
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
      raise SwapFileError, "swap file not setup correctly" unless ((result).to_i > 0)
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

  # Obtains the conntrack_max value from /etc/sysctl.conf configuration file
  #
  # @param server [Server] the server to obtain value from
  #
  # @return [String] conntrack_max value from configuration file
  #
  # @raise [FailedProbeCommandError] if probe fails to obtain conntrack_max value from
  # configuration file
  #
  def obtain_conf_conntrack_max(server)
    conntrack_module_name = "net.netfilter.nf_conntrack_max"
    conf_conntrack_max = ""
    # SSH to the server and obtain the conntrack_max value from
    # /etc/sysctl.conf file
    probe(server,
      %Q{sh -c "grep "#{conntrack_module_name}" /etc/sysctl.conf"}) do |result, status|
      raise FailedProbeCommandError, "Can't probe the server to obtain conntrack_max value from /etc/sysctl.conf" unless status == 0
      puts "conntrack_max value in /etc/sysctl.conf: #{result}"
      conf_conntrack_max = result
      true
    end
    conf_conntrack_max
  end

  # Obtains the conntrack_max value using sysctl command
  #
  # @param server [Server] the server to obtain value from
  #
  # @return [String] conntrack_max value from sysctl commann
  #
  # @raise [FailedProbeCommandError] if probe fails to obtain conntrack_max value from
  # sysctl command
  #
  def obtain_sysctl_conntrack_max(server)
    conntrack_module_name = "net.netfilter.nf_conntrack_max"
    sysctl_conntrack_max = ""
    probe(server,
      %Q{sh -c "sysctl #{conntrack_module_name}"}) do |result, status|
      raise FailedProbeCommandError, "Can't probe the server to obtain conntrack_max value using sysctl" unless status == 0
      puts "conntrack_max value returned by sysctl: #{result}"
      sysctl_conntrack_max = result
      true
    end
    sysctl_conntrack_max
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

  # Reboot to check if functionality works after a reboot on clouds that
  # support reboot.
  if cloud.supports_reboot?
    reboot_all
    wait_for_all("operational")
  else
    puts "Reboot is not supported in this cloud. Skipping..."
  end

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

# The Base conntrack_max test verifies that the sysctl value for conntrack_max
# is loaded properly from the /etc/sysctl.conf. It also validates that the
# value for conntrack_max doesn't get reset after running
# sys_firewall::setup_rule recipe.
#
test_case "conntrack_max" do
  # This test is only applicable to ServerTemplates that use Chef.
  skip unless is_chef?

  # Single server in deployment
  server = servers.first

  # Test 1: Verify that correct conntrack_max value is set in sysctl from conf.
  #
  # Obtain the conntrack_max value set in the /etc/sysctl.conf
  conf_conntrack_max = obtain_conf_conntrack_max(server)

  # Obtain the conntrack_max value returned by the sysctl command
  sysctl_conntrack_max_test1 = obtain_sysctl_conntrack_max(server)

  if conf_conntrack_max == sysctl_conntrack_max_test1
    puts "conntrack_max value is set properly"
  else
    raise ConntrackMaxError, "conntrack_max value is not set properly." +
      " #{conf_conntrack_max} != #{sysctl_conntrack_max_test1}"
  end

  # Test 2: Verify that the value doesn't get reset when an iptables rule is
  # added or removed (iptables gets reloaded).
  #
  # Set a new port as input for sys_firewall::setup_rule. A port that is not
  # already opened should be used for the setup_rule recipe to rebuild
  # iptables. Port 8088 is not used anywhere and commonly used for test
  # purposes.
  #
  server.set_inputs("sys_firewall/rule/port" => "text:8088")

  # Run sys_firewall::setup_rule recipe. Running this recipe will rebuild
  # iptables.
  #
  run_recipe("sys_firewall::setup_rule", s_one)

  # Vefify that conntrack_max value is unchanged (not reset).
  # Obtain the conntrack_max value returned by the sysctl command after running
  # the sys_firewall::setup_rule recipe.
  #
  sysctl_conntrack_max_test2 = obtain_sysctl_conntrack_max(server)

  if sysctl_conntrack_max_test1 == sysctl_conntrack_max_test2
    puts "conntrack_max value is unchanged after running" +
      " sys_firewall::setup_rule recipe"
  else
    raise ConntrackMaxError, "conntrack_max value is changed after running" +
      " sys_firewall::setup_rule recipe"
  end
end
