#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module App
    module Helper
      # Returns array from a comma separated list
      #
      # @param pool_list [String] Comma separated list of URIs or FQDNs to create HAProxy pools for. Example: "/serverid, /appsever, default"
      #
      # @return [Array<String>] Array of pools Example: ["_serverid", "_appsever", "default"]
      def pool_names(pool_list)
        pool_norm_name = pool_list.gsub(/\s+/, "").gsub(/[\/]/, "_").split(",").uniq
      end

    end
  end
end
