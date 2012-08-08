#
# Cookbook Name:: repo_rsync
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class SshKey
      KEYFILE = "/tmp/rsync.key"

      # Create private key file used to connect via ssh.
      #
      # @param ssh_key [string] rsync private ssh key
      #
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

    end
  end
end
