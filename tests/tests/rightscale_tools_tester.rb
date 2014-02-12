# Include helper objects and methods.
require_helper "cloud"
require_helper "rackspace_managed"

# When rerunning a test, shutdown all of the servers.
#
hard_reset do
  stop_all
end

# Before all of the test cases, launch all of the servers in the deployment.
#
before do
  # Get the current cloud
  cloud = Cloud.factory

  # Single server in deployment
  server = servers.first

  # Set the required credential inputs for Rackspace Managed cloud.
  setup_rackspace_managed_credentials(server) \
    if cloud.cloud_name =~ /Rackmanaged/

  launch_all
  wait_for_all("operational")
end

# This test case performs the unit tests for the rightscale_tools project. It
# simply runs the "tester::do_unit_tests" recipe on the server which runs the
# unit tests.
#
test_case "unit_tests" do
  # Single server in deployment
  server = servers.first

  run_script("tester::do_unit_tests", server)
end

# This test case performs the functional tests for the rightscale_tools
# project. It simply runs the "tester::do_functional_tests" recipe on the
# server which runs the functional tests. The functional tests on the
# rightscale_tools project needs some work. Please do not use this test case
# until the work is done in the project.
#
test_case "functional_tests" do
  # Single server in deployment
  server = servers.first

  run_script("tester::do_functional_tests", server)
end
