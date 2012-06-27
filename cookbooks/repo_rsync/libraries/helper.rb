#
# Cookbook Name:: repo_rsync
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class Ssh_key
      KEYFILE = "/tmp/rsync_key"

      # Create private key file used to connect via ssh.
      #
      # @param rsync_key [string] rsync private ssh key
      #
      # @raise [RuntimeError] if ssh key string is empty
      def create(rsync_key)
        Chef::Log.info("  Creating temporary rsync ssh key")
        keyname = rsync_key

        if "#{keyname}" != ""
          keyfile = KEYFILE
          # Writing key to file
          system("echo -n '#{keyname}' > #{keyfile}")
          # Setting permissions
          system("chmod 700 #{keyfile}")
        end
      end


      # Delete SSH key created by "create" method.
      def delete
        Chef::Log.info("  Deleting temporary ssh key")
        keyfile = KEYFILE
        if keyfile != nil
          # Removing previously created files.
          system("rm -f #{keyfile}")
        end
      end

    end
  end
end
