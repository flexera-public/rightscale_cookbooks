def wait_for_ip_repopulation(server)
  # It takes about a minute for IPs to be repopulated.
  puts "Waiting maximum 15 minutes for ips to repopulate"

  # Wipes existing dns settings to facilitate repopulation test.
  server['dns_name'] = nil
  server.private_dns_name = nil

  # Timeout increased to 15 minutes.  There is a bug in core to fix the delay
  # in ip population for instances. If that bug is fixed we can take this down.
  # rightsite ticket is 13987
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
end
