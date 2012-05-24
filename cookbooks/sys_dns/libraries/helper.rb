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
    end # class DNS

    # Applicable to the below classes
    #
    # Parameters:
    # * id:: The unique identifier that is associated with the DNS A record of the server.
    # * user:: The user name that is used to access and modify your DNS A records.
    # * password:: The password that is used to access and modify your DNS A records.
    # * address:: Private IP of instance running the recipe.
    # * region:: CloudDNS specific: region where the A records should be modified.
    #
    # Return:
    # Chef::Log:: A record successful update message.
    #
    # Raise:
    # Chef::Log:: Error message that may have occurred during the update process.

    class AWS < DNS
      def action_set(id, user, password, address)
        zone_id, hostname = id.split(':')

        current_ip= `dig +short #{hostname}`.chomp

        # Generating Route53 secrets file
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

        # Generating record update xml
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

        # Sending the xml to Route53
        result = ""
        #  Simple retry loop, sometimes the DNS call will flake out..
        5.times do |attempt|
          result = `/opt/rightscale/dns/dnscurl.pl --keyfile #{secrets_filename} --keyname my-aws-account -- -X POST -H "Content-Type: text/xml; charset=UTF-8" --upload-file #{cmd_filename} #{endpoint}hostedzone/#{zone_id}/rrset`
          break if result =~ /ChangeResourceRecordSetsResponse/
          @logger.info("DNS change not successful - waiting then retrying - attempt number #{attempt}")
          sleep 5
        end

        # Checking the result
        if result =~ /ChangeResourceRecordSetsResponse/
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end
      end
    end # class AWS < DNS

    class DME < DNS
      def action_set(id, user, password, address)
        # Generating A Record update query and sending the update request
        query="username=#{CGI::escape(user)}&password=#{CGI::escape(password)}&id=#{id}&ip=#{CGI::escape(address)}"
        result = `curl -S -s -o - -f -g 'https://cp.dnsmadeeasy.com/servlet/updateip?#{query}'`

        # Checking the result
        if result =~ /success/ || result =~ /error-record-ip-same/
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, id=#{id}, address:#{address}, output:#{result}"
        end

        result
      end
    end # class DME < DNS

    class DynDNS < DNS
      def action_set(id, user, password, address)
        # Generating A Record update query and sending the update request
        query="hostname=#{CGI::escape(id)}&myip=#{CGI::escape(address)}"
        result = `curl -u #{user}:#{password} -S -s -o - -f -g 'https://members.dyndns.org/nic/update?#{query}'`

        # Checking the result
        if result =~ /nochg #{address}/ || result =~ /good #{address}/
          @logger.info("DNSID #{id} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end

        result
      end
    end # class DynDNS < DNS

    class CloudDNS < DNS
      def action_set(id, user, password, address, region)
        # Getting dns_domain_id && dns_record_id from DNS Record ID input
        dns_domain_id, dns_record_id= id.split(':')

        # Setting the right URLs for selected region
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

        # Getting the Authentication Token and new Service Endpoint
        output = `curl -D - -H "X-Auth-Key: #{password}" -H "X-Auth-User: #{user}" #{auth_url}`
        x_auth_token = ""
        output.each do |line|
          if line =~ /X-Auth-Token:/
            x_auth_token = line.gsub(/X-Auth-Token: /, '').chomp
          end
          if line =~ /X-Server-Management-Url:/
            service_endpoint += line.chomp[/\d+$/]
          end
        end

        # Verifying Domain ID
        output = `curl -k -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains`
        if output =~ /"totalEntries":0/
          raise "No entries found for entered domain ID #{dns_domain_id}."
        end

        # Fetching FQDN by Record ID
        output = `curl -k -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains/#{dns_domain_id}/records/#{dns_record_id}`
        if output =~ /is not a valid A record name/
          raise "Record ID #{dns_record_id} is not a valid A record name."
        else
          fqdn = output[/"name":"(.+)","id":/][$1]
        end

        # Generating new json and sending it over to CloudDNS
        new_ip_json = "{\"name\":\"#{fqdn}\",\"data\":\"#{address}\"}"
        result = `curl -k -X PUT -H "Content-Type: application/json" --data '#{new_ip_json}' -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains/#{dns_domain_id}/records/#{dns_record_id}`

        # Checking the result
        if result =~ /#{fqdn}/
          @logger.info("DNS record for FQDN #{fqdn} set to this instance IP: #{address}")
        else
          raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        end

        result
      end
    end #class CloudDNS < DNS

  end
end
