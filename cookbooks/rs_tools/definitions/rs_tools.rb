#
# Cookbook Name:: rs_tools
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

define :rs_tools, :action => :install do
  # Gem requirements
  ["right_aws", "rest-client", "json", "terminator"].each { |p|  gem_package  p }

  directory "/opt/rightscale" do
    recursive true
  end

  toolname=params[:name]
  if params[ :action ] == :install
    remote_file "/opt/rightscale/#{toolname}" do
      source "#{toolname}"
      cookbook "rs_tools"
    end

    bash "unpack #{toolname}" do
      flags "-ex"
      user "root"
      cwd "/opt/rightscale"
      code <<-EOH
        tar xzf #{toolname}
        tar -tf #{toolname} | xargs chmod ug+x
      EOH
    end
  end
end
