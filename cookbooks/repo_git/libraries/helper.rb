#
# Cookbook Name:: repo
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Repo
    class Ssh_key
     KEYFILE = "/tmp/gitkey"

     # Create bash script, which will set user defined ssh key required to access to private git source code repositories.
     #
     # == Parameters
     # @param git_ssh_key [string] Git private ssh key
     #
     # == Raise
     # @raises [RuntimeError] if ssh key string is empty
     def create(git_ssh_key)
       Chef::Log.info("  Creating ssh key")
       keyfile = nil
       keyname = git_ssh_key

       if "#{keyname}" != ""
         keyfile = KEYFILE
         # Writing key to file
         system("echo -n '#{keyname}' > #{keyfile}")
         # Setting permissions
         system("chmod 700 #{keyfile}")
         # Adding additional parameters
         system("echo 'exec ssh -oStrictHostKeyChecking=no -i #{keyfile} \"$@\"' > #{keyfile}.sh")
         system("chmod +x #{keyfile}.sh")
       end
       # GIT_SSH environment variable.
       ENV["GIT_SSH"] = "#{keyfile}.sh" unless ("#{keyfile}" == "")
     end

     # Delete SSH key created by "create" method, after successful pull operation. And clear GIT_SSH.
     #
     # == Parameters
     #   none
     def delete
       Chef::Log.warn "Deleting ssh key "
        keyfile = KEYFILE
       if keyfile != nil
         # Removing previously created files.
         system("rm -f #{keyfile}")
         system("rm -f #{keyfile}.sh")
       end
     end

    end
  end
end
