# Include the helper objects and methods.
require_helper "cloud"
require_helper "errors"

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

# This test case will run the "tester::do_block_device_api_tests" recipe on the
# server which will run the block device functional tests on rightscale_tools
# to test the API with volume based API calls.
#
test_case "run_api_tests" do
  # Get the current cloud
  cloud = Cloud.factory

  # Single server in deployment
  server = servers.first

  # Set the inputs required for the test.
  if cloud.supports_volumes?
    server.set_inputs("tester/func/cloud_capability/volume" => "text:true")
    if cloud.supports_snapshots?
      server.set_inputs(
        "tester/func/cloud_capability/snapshot" => "text:true"
      )
    else
      server.set_inputs(
        "tester/func/cloud_capability/snapshot" => "text:false"
      )
    end
  else
    raise UnsupportedCloudError, "This cloud #{cloud.cloud_name} doesn't" +
      " support volumes and volume snapshots. API tester requires at least" +
      " volume support for testing."
  end

  # Run the tester::do_block_device_api_tests recipe which runs all the block
  # device functional tests available in the rightscale_tools to test the API
  # calls.
  #
  run_recipe("tester::do_block_device_api_tests", server)
end
