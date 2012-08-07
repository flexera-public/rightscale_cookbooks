#
# Cookbook Name:: repo_rsync
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class RSyncSshKey
      KEYFILE = "/tmp/rsync.key"

      # Create private key file used to connect via ssh.
      #
      # @param rsync_key [string] rsync private ssh key
      #
      # @raise [RuntimeError] if ssh key string is empty
      def create(rsync_key)
        raise "  SSH Key is empty!" unless rsync_key

        Chef::Log.info("  Creating temporary rsync ssh key")
        ::File.open(KEYFILE, "w") do |keyfile|
          keyfile << rsync_key
          keyfile.chmod(0600)

        end
      end


      # Delete SSH key created by "create" method.
      def delete
        Chef::Log.info("  Deleting temporary ssh key")
        ::File.delete(KEYFILE)
      end

    end
  end
end
