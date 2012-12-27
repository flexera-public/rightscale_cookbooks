#
# Cookbook Name:: repo_git
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
      def create(ssh_key, check_host_key)
        @sshkey.create(ssh_key)

        if check_host_key.to_s.empty?
          strict_check = "no"
        else
          Chef::Log.info(" DEBUG: SSH host key -#{check_host_key}-")
          strict_check = "yes"
          @sshkey.add_host_key(check_host_key)
        end

        Chef::Log.info("  Creating GIT_SSH environment variable with options: StrictHostKeyChecking=#{strict_check}")
        ::File.open("#{SshKey::KEYFILE}.sh", "w") do |sshfile|
          sshfile << "exec ssh -o StrictHostKeyChecking=#{strict_check} -i #{SshKey::KEYFILE} \"$@\""
          sshfile.chmod(0777)
        end

        ENV["GIT_SSH"] = "#{SshKey::KEYFILE}.sh"
      end

      # Delete SSH key created by "create" method, after successful pull operation. And clear GIT_SSH.
      def delete
        @sshkey.delete
        ::File.delete("#{SshKey::KEYFILE}.sh")
        ENV.delete("GIT_SSH")
      end

    end
  end
end
