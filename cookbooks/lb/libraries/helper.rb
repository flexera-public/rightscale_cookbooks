#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module LB
    module Helper

      # @param [String] vhost_name virtual hosts name.
      #
      # @return [Set] attached_servers set of attached servers for vhost i.e., servers in lb config dir
      #
      def get_attached_servers(vhost_name)
        attached_servers = Set.new
        haproxy_d = "/home/lb/#{node[:lb][:service][:provider]}.d/#{vhost_name}"
        Dir.entries(haproxy_d).select do |file|
          next if file == "." or file == ".."
          attached_servers.add?(file)
        end if (::File.directory?(haproxy_d))

        attached_servers
      end # def get_attached_servers(vhost_name)

      # @param [String] vhost_name virtual hosts name.
      #
      # @return [Hash] app_servers hash of app servers in deployment answering for vhost_name
      #
      def query_appservers(vhost_name)
        app_servers = Hash.new

        r=rightscale_server_collection 'app_servers' do
          tags ["loadbalancer:#{vhost_name}=app"]
          secondary_tags ["server:uuid=*", "appserver:listen_ip=*", "appserver:listen_port=*"]
          action :nothing
        end
        r.run_action(:load)

        node[:server_collection]['app_servers'].to_hash.values.each do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('appserver:listen_ip', tags)
          port = RightScale::Utils::Helper.get_tag_value('appserver:listen_port', tags)

          pool_name = RightScale::Utils::Helper.get_tag_value('appserver:pool_name', tags)
          backend_fqdn = RightScale::Utils::Helper.get_tag_value('appserver:backend_fqdn', tags)
          backend_uri_path = RightScale::Utils::Helper.get_tag_value('appserver:backend_url_path', tags)

          app_servers[uuid] = {}
          app_servers[uuid][:ip] = ip
          app_servers[uuid][:backend_port] = port.to_i

          app_servers[uuid][:pool_name] = pool_name
          app_servers[uuid][:backend_fqdn] = backend_fqdn
          app_servers[uuid][:backend_uri_path] = backend_uri_path
        end

        app_servers
      end # def query_appservers(vhost_name)

    end
  end
end
