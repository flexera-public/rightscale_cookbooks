#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class SshKey
      KEYFILE = "/tmp/ssh.key"

      # Create private key file used to connect via ssh.
      #
      # @param [String] ssh_key rsync private ssh key
      # @raise [RuntimeError] if ssh key string is empty
      def create(ssh_key)
        raise "  SSH key is empty!" unless ssh_key

        Chef::Log.info("  Creating temporary SSH key")
        ::File.open(KEYFILE, "w") do |keyfile|
          keyfile << ssh_key
          keyfile.chmod(0600)
        end
      end

      # Delete SSH key created by "create" method.
      def delete
        Chef::Log.info("  Deleting temporary data")
        ::File.delete(KEYFILE)
      end

      # Create record in /root/.ssh/known_hosts
      #
      # @param [String] host_key host_key record: fqdn,ip ssh-rsa value
      def add_host_key(host_key)
        host_file = "/root/.ssh/known_hosts"
        if ::File.exists?("#{host_file}") && ::File.readlines(host_file).grep("#{host_key}\n").any?
          Chef::Log.info("  Skipping key installation. Looks like the key already exists.")
        else
          Chef::Log.info("  Installing ssh host key for root.")
          ::File.open(host_file, "a") do |known_hosts|
            known_hosts << "#{host_key}\n"
            known_hosts.chmod(0600)
          end
        end
      end
    end
  end
end
