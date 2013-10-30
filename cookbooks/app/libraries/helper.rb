#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

module RightScale
  module App
    module Helper
      # Returns an array of pool names from a comma separated list.
      #
      # @param pool_list [String] comma separated list of URIs or FQDNs to create
      # HAProxy pools for. Example: "/serverid, /appsever, default"
      #
      # @return [Array<String>] array of pools (Example: ["_serverid", "_appsever", "default"])
      #
      def pool_names(pool_list)
        pool_norm_name = pool_list.gsub(/\s+/, "").gsub(/[\/]/, "_").split(",").uniq
      end

      # Returns an array of versions of the RightScript-based ServerTemplate
      # Application servers found in the deployment.
      #
      # @param [String] pool_name loadbalancing pool name
      #
      # @return [Array<String>] array of ServerTemplate versions found
      #
      def get_rsb_app_servers_version(pool_name)
        # Removes any characters except alphabets and numbers.
        pool_name.delete!("^0-9A-Za-z]")

        rightscale_server_collection "#{pool_name}_rsb_app_servers" do
          tags "loadbalancer:#{pool_name}=app"
          mandatory_tags "server_template:version=*"
          action :nothing
        end.run_action(:load)

        versions = Array.new
        node[:server_collection]["#{pool_name}_rsb_app_servers"].to_hash.values.
          each do |tags|
          versions = versions |
            [RightScale::Utils::Helper.get_tag_value('server_template:version', tags)]
        end
        versions
      end

    end
  end
end
