#
# Cookbook Name:: app
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module App
    module Helper
      
      # Return the IP address of the interface that this application server 
      # listens on.
      #
      # @param private_ips [Array] List of private ips assigned to the application server
      # @param public_ips [Array] List of public ips assigned to the application server
      #
      # @return [String] IP Address
      #
      # @raises [RuntimeError] If nether a valid private nor public ip can be found
      def self.bind_ip(private_ips = [ ], public_ips = [ ])
        ip = nil
        if private_ips && private_ips.size > 0
          ip = private_ips[0] # default to first private ip
        elsif public_ips && public_ips.size > 0
          ip = public_ips[0]  # default to first public ip
        elseif
          raise "ERROR: cannot detect a bind address on this application server."
        end
        ip
      end
      
      # Return the port that this application server listens on
      #
      # @return [integer] Application port
      def self.bind_port()
        node[:app][:port].to_i
      end

      # Returns array from a comma separated list
      #
      # @param pool_list [String] Comma separated list of URIs or FQDNs to create HAProxy pools for. Example: "/serverid, /appsever, default"
      #
      # @return [Array<String>] Array of pools Example: ["/serverid", "/appsever", "default"]
      def pool_names(pool_list)
        pool_norm_name = pool_list.gsub(/[\/]/, '_').split(", ").uniq
      end

    end
  end
end
