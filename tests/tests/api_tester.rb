# Include the helper objects and methods.
require_helper "cloud"
require_helper "errors"

helpers do
  def set_inputs(cloud, server)
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
    end
  end
end

hard_reset do
  stop_all
end

before do
  launch_all
  wait_for_all("operational")
end

test_case "run_api_tests" do
  # Get the current cloud
  cloud = Cloud.factory

  # To perform this test, the cloud should at least support volumes.
  skip unless cloud.supports_volumes?

  # Single server in deployment
  server = servers.first
  # Set the inputs required for the test.
  set_inputs(cloud)
  # Run the tester::do_block_device_api_tests recipe which runs all the
  # functional tests available in the rightscale_tools to test the API calls.
  #
  run_recipe("tester::do_block_device_api_tests", server)
end
