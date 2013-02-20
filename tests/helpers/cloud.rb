# Represents a cloud with methods that encapsulate cloud specific behavior.
#
class Cloud
  extend VirtualMonkey::TestCase::Mixin

  # Factory that returns an instance of the specific Cloud subclass for a given
  # test run.
  #
  # @return [Cloud] an instance of the specific Cloud subclass
  #
  def self.factory
    case get_cloud_name
    when /^AWS /
      EC2.new
    else
      Cloud.new
    end
  end

  # Checks if a server has stop/start support.
  #
  # @param server [Server] the server to check for stop/start support.
  #
  # @return [Boolean] whether the server supports stop/start.
  #
  def supports_start_stop?(server)
    false
  end

  # Gets the name of the MCI used on a Server.
  #
  # @param server [Server]
  #
  def get_server_mci_name(server)
    # TODO
  end
end

# Represents the Amazon EC2 cloud specific behavior.
#
# @see Cloud
#
class EC2 < Cloud
  # Checks if a server has stop/start support.
  #
  # @param server [Server] the server to check for stop/start support.
  #
  # @return [Boolean] whether the server supports stop/start.
  #
  # @see Cloud#supports_start_stop?
  #
  def supports_start_stop?(server)
    # Only EC2 EBS images support start/stop.
    # All RHEL images are EBS, but may not say so.
    if (get_mci_name(server).downcase =~ /ebs|rhel/)
      true
    else
      false
    end
  end
end
