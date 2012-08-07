#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class GitSshKey
      KEYFILE = "/tmp/gitkey"

      # Create bash script, which will set user defined ssh key required to access to private git source code repositories.
      #
      # @param git_ssh_key [string] Git private ssh key
      #
      # @raises [RuntimeError] if ssh key string is empty
      def create(git_ssh_key)
        raise "  SSH Key is empty!" unless git_ssh_key

        Chef::Log.info("  Creating ssh key")

        ::File.open(KEYFILE, "w") do |keyfile|
          keyfile << git_ssh_key
          keyfile.chmod(0600)
        end

        ::File.open("#{KEYFILE}.sh", "w") do |sshfile|
          sshfile << "exec ssh -oStrictHostKeyChecking=no -i #{KEYFILE} \"$@\""
          sshfile.chmod(0777)
        end

        ENV["GIT_SSH"] = "#{KEYFILE}.sh"
      end


      # Delete SSH key created by "create" method, after successful pull operation. And clear GIT_SSH.
      def delete
        Chef::Log.warn "Deleting ssh key "
        ::File.delete(KEYFILE)
        ::File.delete("#{KEYFILE}.sh")
      end

    end
  end
end
