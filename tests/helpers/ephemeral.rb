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

# Verifies the file system type set up on the ephemeral drive.
#
# @param server [Server] the server to check ephemeral drive file type on
# @param fs_type [String] the file system type expected to be set on the
# ephemeral drive
#
# @raise [RuntimeError] if the ephemeral drive file system type is not the same
# as expected file system type
#
def verify_ephemeral_file_system_type(server, fs_type)
  probe(server, "df -T /mnt/ephemeral | grep -c #{fs_type}") do |result, status|
    puts result
    raise "Ephemeral file system type is not '#{fs_type}'" unless status == 0
    puts "Ephemeral file system type is '#{fs_type}'"
    true
  end
end
