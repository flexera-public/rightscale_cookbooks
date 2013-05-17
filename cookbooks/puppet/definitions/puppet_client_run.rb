#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

define :puppet_client_run do

  begin
    # Performs certificate registration on the Puppet Master and returns exit
    # code 2 as success
    execute "run puppet-client" do
      command "puppet agent --test"
      returns 2
      creates "/var/lib/puppet/ssl/certs/" +
        "#{node[:puppet][:client][:node_name]}.pem"
      notifies :start, resources(:service => "puppet")
    end
  rescue Exception => e
    log "  Puppet Client certificate registration failed. Your Puppet Master" +
      " may not be Operational or it is not auto-signing client certificates." +
      " Ensure client certificate is signed on the Puppet Master and run" +
      " recipe puppet::reload_agent"
  end

end
