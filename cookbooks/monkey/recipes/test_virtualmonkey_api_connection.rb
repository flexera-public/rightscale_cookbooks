#
# Cookbook Name::monkey
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

rightscale_marker :begin

log "Testing RightScale credentials are set properly"
unless node[:monkey][:rest][:right_email] &&
  node[:monkey][:rest][:right_passwd] &&
  node[:monkey][:rest][:right_acct_id] &&
  node[:monkey][:rest][:right_subdomain]
  raise "Can't verify API connectivity without RightScale Email," +
    " RightScale Password, RightScale Account ID, and RightScale Subdomain set."
end

# Regular ruby_blocks use sandbox ruby so we're using a script block
# and specifying which interpreter to use

log "Testing API connectivity"
script "Testing API connectivity" do
  interpreter "/usr/bin/ruby"
  code <<-EOH
    $LOAD_PATH.unshift(File.join("", "root", "virtualmonkey", "lib"))
    ENV['REST_CONNECTION_LOG'] = File.join("", "dev", "null")

    require 'rubygems'
    require 'virtualmonkey'
    errors = []

    unless VirtualMonkey::Toolbox::api0_1?
      puts "Without API0.1 access, you will be limited to using grinder."
    end
    puts "Checked API 0.1 connectivity"

    unless VirtualMonkey::Toolbox::api1_0?
      raise "User does not have access to API 1.0 for account entered"
    end
    puts "Checked API 1.0 connectivity"

    if VirtualMonkey::Toolbox::api0_1?
      s3 = Fog::Storage.new(
        :provider => 'AWS',
        :aws_access_key_id => Fog.credentials[:aws_access_key_id_test],
        :aws_secret_access_key => Fog.credentials[:aws_secret_access_key_test])

      if directory = s3.directories.detect { |d| d.key == "#{node[:monkey][:fog][:s3_bucket]}" }
        puts "Found directory, re-using"
      else
        directory = s3.directories.create(
          :key => "#{node[:monkey][:fog][:s3_bucket]}"
        )
      end

      unless directory
        raise "Could not create directory #{node[:monkey][:fog][:s3_bucket]}," +
          " please ensure you have the proper access keys."
      end
    end
  EOH
end

rightscale_marker :end
