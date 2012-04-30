#
# Cookbook Name:: lb
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module LB
    module Helper

      # Returns set of attached servers for vhost i.e., servers in lb config dir
      def get_attached_servers(vhost_name)
        attached_servers = Set.new
        haproxy_d = "/home/lb/#{node[:lb][:service][:provider]}.d/#{vhost_name}"
        Dir.entries(haproxy_d).select do |file|
          next if file == "." or file == ".."
          attached_servers.add?(file)
        end if (::File.directory?(haproxy_d))
        return attached_servers
      end

      # Returns hash of app servers in deployment answering for vhost_name
      def query_appservers(vhost_name)
        app_servers = Hash.new

        r=rightscale_server_collection 'app_servers' do
          tags           [ "loadbalancer:#{vhost_name}=app" ]
          secondary_tags [ "server:uuid=*", "loadbalancer:backend_ip=*", "loadbalancer:backend_port=*" ]
          action :nothing
        end
        r.run_action(:load)

        node[:server_collection]['app_servers'].to_hash.values.each do |tags|
          uuid = RightScale::Utils::Helper.get_tag_value('server:uuid', tags)
          ip = RightScale::Utils::Helper.get_tag_value('loadbalancer:backend_ip',tags)
          port = RightScale::Utils::Helper.get_tag_value('loadbalancer:backend_port',tags)
          app_servers[uuid] = ip
          app_servers[backend_port] = port.to_i
        end

        return app_servers
      end

    end
  end
end
