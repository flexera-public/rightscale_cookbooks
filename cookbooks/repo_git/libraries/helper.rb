#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class GitSshKey

      def initialize
        @sshkey = SshKey.new
      end

      # Create bash script, which will set user defined ssh key required to access to private git source code repositories.
      #
      # @param ssh_key [string] Git private ssh key
      #
      # @raises [RuntimeError] if ssh key string is empty
      def create(ssh_key)
        @sshkey.create(ssh_key)

        Chef::Log.info("  Creating GIT_SSH environment variable")
        ::File.open("#{KEYFILE}.sh", "w") do |sshfile|
          sshfile << "exec ssh -o StrictHostKeyChecking=no -i #{KEYFILE} \"$@\""
          sshfile.chmod(0777)
        end

        ENV["GIT_SSH"] = "#{KEYFILE}.sh"
      end


      # Delete SSH key created by "create" method, after successful pull operation. And clear GIT_SSH.
      def delete
        @sshkey.delete
        ::File.delete("#{KEYFILE}.sh")
      end

    end
  end
end
