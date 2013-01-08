# Reports when a server's IP address has been repopulated.
# There is a bug in core to fix the delay in ip population for instances.
# Will be deprecated when rightsite ticket 13987 is completed.
#
# @param server [Server] Server to monitor for IP repopulation.
#
# @return [Boolean] True when complete.
def wait_for_ip_repopulation(server)
  puts "Waiting maximum 15 minutes for ips to repopulate"

  # Wipes existing dns settings to facilitate repopulation test.
  server['dns_name'] = nil
  server.private_dns_name = nil

  # Timeout increased to 15 minutes.
  # It takes about a minute for IPs to be repopulated.
  Timeout::timeout(15*60) do
    while server['dns_name'] == nil
      # Repopulats hash with dns info if available.
      server.settings

      puts "CURRENT IP <#{server['dns_name']}>"
      puts "CURRENT FQDN <#{server.private_dns_name}>"

      # Check every 2 seconds.
      sleep 2
    end
  end
  true
end
