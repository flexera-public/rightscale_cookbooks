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

    class CloudDNS < DNS
      def action_set(id, user, password, address, clouddns_region, clouddns_domain_id)

        # assign links for regions
        # case "$RAX_REGION" in
        # ORD*   ) echo "Chicago" && auth_url="https://auth.api.rackspacecloud.com/v1.0" && service_endpoint="https://dns.api.rackspacecloud.com/v1.0/";;
        # DFW*   ) echo "Dallas" && auth_url="https://auth.api.rackspacecloud.com/v1.0" && service_endpoint="https://dns.api.rackspacecloud.com/v1.0/";;
        # LON*   ) echo "London" && auth_url="https://lon.auth.api.rackspacecloud.com/v1.0" && service_endpoint="https://lon.dns.api.rackspacecloud.com/v1.0/";;
        # *       ) echo "unsupported region" && exit 1;;
        # esac
        case clouddns_region
          when "Chicago" or "Dallas"
            auth_url = "https://auth.api.rackspacecloud.com/v1.0"
            service_endpoint = "https://dns.api.rackspacecloud.com/v1.0/"
          when "London"
            auth_url = "https://lon.auth.api.rackspacecloud.com/v1.0"
            service_endpoint = "https://lon.dns.api.rackspacecloud.com/v1.0/"
          else
            raise "Don't override CloudDNS region dropdown options."
        end

        # assign dns_record_ip
        # case "$DNS_RECORD_IP" in
        # Public   ) DNS_RECORD_IP=$RS_PUBLIC_IP;;
        # Private   ) DNS_RECORD_IP=$RS_PRIVATE_IP;;
        # *       ) echo "Using the defined IP";;
        # esac
        # TODO    though looks like already passed by sys_dns::do_set_private: address node[:cloud][:private_ips][0]

        # auth and setup variables
        # output=`curl -D - -H "X-Auth-Key: $RACKSPACE_API_TOKEN" -H "X-Auth-User: $RACKSPACE_USERNAME" $auth_url 2>&1`
        output = `curl -D - -H "X-Auth-Key: #{password}" -H "X-Auth-User: #{user}" #{auth_url}` # password is actually the CloudDNS API key

        # x_auth_token = `grep -i "X-Auth-Token:"<<<"$output" | awk '{print $2}' | sed -e 's/\s//g'`
        x_auth_token = "" # or else it will be local
        output.each do |line|
          if line =~ /X-Auth-Token:/                        # finds the line with "X-Auth-Token:" in output
            x_auth_token = line.gsub!(/X-Auth-Token: /, '') # cuts out the "X-Auth-Token: " part and saves the x_auth_token
          end
        end

        # account_id = `grep -i "X-Server-Management-Url"<<<"$output" | sed -r 's/.+\/([0-9]+).*/\1/'`
        # service_endpoint+=$account_id
        output.each do |line|
          if line =~ /X-Server-Management-Url:/ # finds the line with "X-Server-Management-Url:" in output
            service_endpoint += line[/\d+$/]    # adds the account id (last several digits in url) to service_endpoint for further use
          end
        end # merge this with previous block later

        # list available domains
        # curl -k -H "X-Auth-Token: $x_auth_token" $service_endpoint/domains.xml | sed "s/>/>\n/g"
        # `curl -k -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains.xml`                                            # why do we run this?

        # list records for domain "$DNS_DOMAIN_ID"      TODO: what is $DNS_DOMAIN_ID should i get it as an input?  sys_dns/clouddns_domain_id
        # curl -k -H "X-Auth-Token: $x_auth_token" $service_endpoint/domains/$DNS_DOMAIN_ID/records.xml | sed "s/>/>\n/g"
        # `curl -k -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains/#{dns_domain_id}/records.xml`                   # and this?
                                                                                                                                  # just for info, right?

        # get the record name for "$DNS_RECORD_ID"
        # output = `curl -k -H "X-Auth-Token: $x_auth_token" $service_endpoint/domains/$DNS_DOMAIN_ID/records.xml`
        # dns_record_name = `sed -r 's/.+record id="'$DNS_RECORD_ID'" [^>]*?name="(\S+)".+>/\1/'<<<"$output"`
        output = `curl -k -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains/#{clouddns_domain_id}/records.xml`
        dns_record_name = ""

        # need to find dns_record_id but don't know how the output looks like
        # output.each do |line|
        #   if something
        #     dns_record_name = gets a value
        #   end
        # end

        # update IP($DNS_RECORD_IP) for record id "$DNS_RECORD_ID", domain id "$DNS_DOMAIN_ID"
        # new_ip_json = '{ "name":"'$dns_record_name'", "data":"'$DNS_RECORD_IP'", "comment":"updated by a RightScale script" }'
        new_ip_json = "{ \"name\":\"'#{dns_record_name}'\", \"data\":\"'#{address}'\", \"comment\":\"updated by RightScale\" }"

        #curl -k -X PUT -H Content-Type:\ application/json --data "$new_ip_json" -H "X-Auth-Token: $x_auth_token" $service_endpoint/domains/$DNS_DOMAIN_ID/records/$DNS_RECORD_ID
        result = `curl -k -X PUT -H Content-Type:\\ application/json --data "#{new_ip_json}" -H "X-Auth-Token: #{x_auth_token}" #{service_endpoint}/domains/#{clouddns_domain_id}/records/#{dns_record_name}`

        # must have a check too but don't have anything to use yet

        # if(result =~ /success/ ) then
        #   @logger.info("DNSID #{dns_record_name} set to this instance IP: #{address}")
        # else
        #   raise "Error setting the DNS, curl exited with code: #{$?}, output: #{result}"
        # end

        # result
      end
    end
  end
end
