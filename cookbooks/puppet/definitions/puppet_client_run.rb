#
# Cookbook Name:: puppet
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

define :puppet_client_run, :touchfile => nil do

  # Runs the Puppet Client to create a new SSL certificate and register on the
  # Puppet Server.
  begin
    execute "run puppet-client" do
      command "puppet agent --test"
      returns 2
      creates params[:touchfile]
      notifies :start, resources(:service => "puppet")
    end
  rescue Exception => e
    log "  Puppet Client certificate registration failed. Your Puppet Server" +
      " may not be Operational or it is not auto-signing client certificates." +
      " Make sure client certificate is signed on the Puppet Server and run" +
      " recipe puppet::reload_agent"
  end

end
