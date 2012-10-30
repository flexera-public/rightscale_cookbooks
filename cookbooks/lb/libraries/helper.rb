#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module LB
    module Helper

      # @param [String] pool_name virtual hosts name.
      #
      # @return [Set] attached_servers set of attached servers which will be in the same pool i.e., servers in lb config dir
      #
      def get_attached_servers(pool_name)
        attached_servers = Set.new
        haproxy_d = "/etc/haproxy/#{node[:lb][:service][:provider]}.d/#{pool_name}"
        Dir.entries(haproxy_d).select do |file|
          next if file == "." or file == ".."
          attached_servers.add?(file)
        end if (::File.directory?(haproxy_d))

        attached_servers
      end

      # @param [String] pool_name virtual hosts name.
      #
      # @return [Hash] app_servers hash of app servers in deployment answering for pool_name
      #
      def query_appservers(pool_name)
        app_servers = Hash.new

        # See cookbooks/rightscale/providers/server_collection.rb for the "load" action
        r=rightscale_server_collection 'app_servers' do
          tags ["loadbalancer:#{pool_name}=app"]
          secondary_tags ["server:uuid=*", "appserver:listen_ip=*", "appserver:listen_port=*"]
          action :nothing
        end
        r.run_action(:load)

        node[:server_collection]['app_servers'].to_hash.values.each do |tags|
          # See cookbooks/rightscale/libraries/helper.rb for the "get_tag_value" method.
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('appserver:listen_ip', tags)
          port = RightScale::Utils::Helper.get_tag_value('appserver:listen_port', tags)
          app_servers[uuid] = {}
          app_servers[uuid][:ip] = ip
          app_servers[uuid][:backend_port] = port.to_i
        end

        app_servers
      end

    end
  end
end
