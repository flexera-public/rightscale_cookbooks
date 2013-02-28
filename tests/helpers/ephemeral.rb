# Checks if an ephemeral drive is mounted to /mnt/ephemeral on a server.
#
# @param server [Server] the server to check /mnt/ephemeral on
#
# @raise [RuntimeError] if an ephemeral drive is not mounted to /mnt/ephemeral
#
def check_ephemeral_mount(server)
  probe(server, "mountpoint /mnt/ephemeral") do |result, status|
    raise "an ephemeral drive is not mounted to /mnt/ephemeral" unless status == 0
    puts "an ephemeral drive is mounted to /mnt/ephemeral"
    true
  end
end
