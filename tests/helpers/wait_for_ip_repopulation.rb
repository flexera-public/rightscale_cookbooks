def wait_for_ip_repopulation(server)
  #it takes about a minute for ips to get repopulated.
  puts "Waiting maximum 15 minutes for ips to repopulate"
  server['dns_name'] = nil
  server.private_dns_name = nil
  # Timeout increased to 15 minutes.  There is a bug in core to fix the delay
  # in ip population for instances. If that bug is fixed we can take this down.
  # rightsite ticket is 13987
  Timeout::timeout(15*60) do
    while server['dns_name'] == nil
      server.settings # repopulates hash with ip
      puts "CURRENT IP <#{server['dns_name']}>"
      puts "CURRENT FQDN <#{server.private_dns_name}>"
      sleep 2
    end
  end
end