
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

test_case "unit_tests" do
  # Single server in deployment
  server = servers.first

  run_script("tester::do_unit_tests", server)
end

test_case "functional_tests" do
  # Single server in deployment
  server = servers.first

  run_script("tester::do_functional_tests", server)
end
