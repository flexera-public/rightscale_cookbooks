#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

require 'cgi'
require 'logger'

module RightScale
  module DnsTools
    class DNS
      def initialize(logger = nil)
        @logger = logger || Logger.new(STDOUT)
      end

      def action_set(id, user, password, address)
        raise 'Not implemented!'
      end
    end

    class AWS < DNS
      def action_set(id, user, password, address)
        zone_id, hostname = id.split(':')

        current_ip= `dig +short #{hostname}`.chomp

        aws_cred=<<EOF
%awsSecretAccessKeys = (
    "my-aws-account" => {
        id => "#{user}",
        key => "#{password}",
    },
);
EOF
        secrets_filename="/root/.aws-secrets"
        File.open(secrets_filename, "w") { |f| f.write aws_cred }
        File.chmod(0600, secrets_filename)

        endpoint = "https://route53.amazonaws.com/2010-10-01/"
        xml_doc = "https://route53.amazonaws.com/doc/2010-10-01/"
        ttl = 60
        record_type = 'A'

        modify_cmd=<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ChangeResourceRecordSetsRequest xmlns="#{xml_doc}">
  <ChangeBatch>
    <Comment>
    Modified by RightScale
    </Comment>
    <Changes>
      <Change>
        <Action>DELETE</Action>
        <ResourceRecordSet>
          <Name>#{hostname}.</Name>
          <Type>#{record_type}</Type>
          <TTL>#{ttl}</TTL>
          <ResourceRecords>
            <ResourceRecord>
              <Value>#{current_ip}</Value>
            </ResourceRecord>
          </ResourceRecords>
        </ResourceRecordSet>
      </Change>
      <Change>
        <Action>CREATE</Action>
        <ResourceRecordSet>
          <Name>#{hostname}.</Name>
          <Type>#{record_type}</Type>
          <TTL>#{ttl}</TTL>
          <ResourceRecords>
            <ResourceRecord>
              <Value>#{address}</Value>
            </ResourceRecord>
          </ResourceRecords>
        </ResourceRecordSet>
      </Change>
    </Changes>
  </ChangeBatch>
</ChangeResourceRecordSetsRequest>
EOF
        cmd_filename="/tmp/modify.xml"

        @logger.info("Changing IP for '#{hostname}' from '#{current_ip}' to '#{address}'")

        File.open(cmd_filename, "w") { |f| f.write modify_cmd }

        result = ""
        # Simple retry loop, sometimes the DNS call will flake out..
        5.times do |attempt|
          result = `/opt/rightscale/dns/dnscurl.pl --keyfile #{secrets_filename} --keyname my-aws-account -- -X POST -H "Content-Type: text/xml; charset=UTF-8" --upload-file #{cmd_filename} #{endpoint}hostedzone/#{zone_id}/rrset`
          break if result =~ /ChangeResourceRecordSetsResponse/
          @logger.info("DNS change not successful - waiting then retrying - attempt number #{attempt}")
          sleep 5
        end

        if(result =~ /ChangeResourceRecordSetsResponse/ ) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end
      end
    end

    class DME < DNS
      def action_set(id, user, password, address)
        query="username=#{CGI::escape(user)}&password=#{CGI::escape(password)}&id=#{id}&ip=#{CGI::escape(address)}"
        result = `curl -S -s -o - -f -g 'https://cp.dnsmadeeasy.com/servlet/updateip?#{query}'`

        if( result =~ /success/ || result =~ /error-record-ip-same/   ) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, id=#{id}, address:#{address}, output:#{result}"
        end

        result
      end
    end

    class DynDNS < DNS
      def action_set(id, user, password, address)
        query="hostname=#{CGI::escape(id)}&myip=#{CGI::escape(address)}"
        result = `curl -u #{user}:#{password} -S -s -o - -f -g 'https://members.dyndns.org/nic/update?#{query}'`

        if(result =~ /nochg #{address}/ || result =~ /good #{address}/) then
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end

        result
      end
    end

=begin
    class CloudDNS < DNS
      def action_set(id, user, password, address, region)

        # id = id of the dns entry
        # address = IP to change DNS entry to

        case region
          when "Chicago", "Dallas"
            auth_url = "https://auth.api.rackspacecloud.com/v1.0"
            service_endpoint = "https://dns.api.rackspacecloud.com/v1.0/"
          when "London"
            auth_url = "https://lon.auth.api.rackspacecloud.com/v1.0"
            service_endpoint = "https://lon.dns.api.rackspacecloud.com/v1.0/"
          else
            raise "Unsupported region '#{region}'."
        end

        # get tmp token and account_id
        x_auth_info = `curl -D - -H "X-Auth-Key: #{password}" -H "X-Auth-User: #{user}" $auth_url`
        account_id = string commands to get  X-Server-Management-Url: get last number at end of string
                    ie https://servers.api.rackspacecloud.com/v1.0/418866

        auth_token = String commands to get X-Auth-Token: to get token
                     ie X-Auth-Token: 15eb6e74-893b-4fbe-bd26-2d101a159c17

        service_endpoint << account_id

        # grab domain ID from domain name of address
        
        domain_info = `curl -k -H "X-Auth-Token: #{auth_token}" $service_endpoint/domains?name=#{address.split(".").drop(1).join(".")}`
# example output:        {"domains":[{"name":"test-rightscale.com","id":3251446,"comment":"This would be my comment","updated":"2012-05-11T18:55:44.000+0000","created":"2012-05-11T18:55:43.000+0000"}],"totalEntries":1}
        domain_id = ruby code to extract from domain_info  - shoul derror out if you get nothing ie: {"domains":[],"totalEntries":0}

        # set  record
        new_ip_jason="{ \"name\":\"#{id}\", \"data\":\"#{address}\", \"comment\":\"updated by a RightScale recipe\" }"
        result = `curl -k -X PUT -H "Content-Type: application/json --data "#{new_ip_jason}" -H "X-Auth-Token: #{auth_token}"`
      
     
        comfirm result is what we want          

      end
    end
=end

  end
end
