# input: server_template_type = {hef, rsb}

# Include the helper methods.
helper_include "cloud"
helper_include "wait_for_ip_repopulation"

helpers do
  # Taken from the old feature file.
  def test_swapspace
	  probe(servers.first, "grep -c /swapfile /proc/swaps") { |result, status|
	    print "grep -c /swapfile /proc/swaps returned = " + result.to_s
	    raise "raise swap file not setup correctly" unless ((result).to_i > 0)
	    true
    }
  end

  # base_chef is currently a superset of base_rsb.
  is_chef = (suite_variables[:server_template_type] == "chef")
end

hard_reset do
  stop_all
end

before do
  launch_all
  wait_for_all("operational")

  if is_chef
    load_script('fix_ssh', RightScript.new('href' => '/api/acct/2901/right_scripts/306150001'))
    run_script_on_set('fix_ssh', @servers, true, {'PUBKEY' => 'cred:publish-test.pub' })
  end
end

test "smoke_test" do
  if is_chef
    verify_ephemeral_mounted
    test_swapspace
  end

  check_monitoring

  reboot_all
  wait_for_all("operational")

  if is_chef
    verify_ephemeral_mounted
    test_swapspace
  end

  check_monitoring
end

test "ebs_stop_start" do
  skip unless is_chef

  cloud = Cloud.factory
  skip unless cloud.supports_start_stop_on_server?(server)

  # Single server in deployment.
  server = servers.first

  # Stop EBS image.
  puts "Stopping current server."
  server.stop_ebs
  wait_for_server_state(server,"stopped")

  # Start EBS image.
  puts "Starting current server."
  server.start_ebs
  wait_for_server_state(server,"operational")
  # It takes about a minute for ips to get repopulated.
  wait_for_ip_repopulation(server)

  verify_ephemeral_mounted
  remove_public_ip_tags
  check_monitoring
end