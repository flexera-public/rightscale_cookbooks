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
    cloud_name = get_cloud_name
    case cloud_name
    when nil, ""
      # TODO: raise some sort of exception in the monkey exception hierarchy
      raise "get_cloud_name returned an invalid value: #{cloud_name}"
    when /^AWS /
      EC2.new cloud_name
    when /^Azure /
      Azure.new cloud_name
    when /^CS /, /^Datapipe /, /^IDC Frontier /, "Logicworks"
      CloudStack.new cloud_name
    when /Openstack/i, "HP Cloud", "Rackspace Private"
      Openstack.new cloud_name
    else
      Cloud.new cloud_name
    end
  end

  # The name of the cloud represented by this object.
  #
  # @return [String] the name of the cloud
  #
  attr_reader :cloud_name

  # Checks if a server can have ephemeral devices.
  #
  # @param server [Server] the server to check for ephemeral support
  #
  # @return [Boolean] whether the cloud supports ephemeral devices
  #
  def supports_ephemeral?(server)
    false
  end

  # Checks if a server has stop/start support.
  #
  # @param server [Server] the server to check for stop/start support
  #
  # @return [Boolean] whether the server supports stop/start
  #
  def supports_start_stop?(server)
    false
  end

  # Checks if the cloud is configured in a way where SSH must be done to a
  # private IP address from within the cloud.
  #
  # @return [Boolean] whether to SSH to a private IP address within the cloud
  #
  def needs_private_ssh?
    false
  end

  # Gets the MCI used on a Server.
  #
  # @param server [Server] the server to get the MCI from
  #
  # @return [MultiCloudImage] the MCI used on the server
  #
  def get_server_mci(server)
    if server.multicloud
      server.reload_as_current
      mci_id = server.current_instance.multi_cloud_image.split('/').last.to_i
    else
      # Legacy EC2 servers don't have a way of discovering their MCI. To work
      # around this the monkey adds a tag to the deployment which is the ID of
      # the MCI used for all of the servers.
      deployment = Deployment.find(server.deployment_href)
      mci_id_tag = deployment.get_info_tags["self"].find do |tag, _|
        tag =~ /mci_id/
      end
      mci_id = mci_id_tag.last.to_i
    end

    MultiCloudImage.find mci_id
  end

private
  def initialize(cloud_name)
    @cloud_name = cloud_name
  end
end

# Represents the Amazon EC2 cloud specific behavior.
#
# @see Cloud
#
class EC2 < Cloud
  # Checks if a server can have ephemeral devices.
  #
  # @param server [Server] the server to check for ephemeral support
  #
  # @return [Boolean] whether the cloud supports ephemeral devices
  #
  # @see Cloud#supports_ephemeral?
  #
  def supports_ephemeral?(server)
    # Ephemeral is not supported on EC2 HVM instances.
    if get_server_mci(server).name =~ /hvm/i
      false
    else
      true
    end
  end

  # Checks if a server has stop/start support.
  #
  # @param server [Server] the server to check for stop/start support
  #
  # @return [Boolean] whether the server supports stop/start
  #
  # @see Cloud#supports_start_stop?
  #
  def supports_start_stop?(server)
    # Only EC2 EBS images support start/stop.
    # All RHEL images are EBS, but may not say so.
    if get_server_mci(server).name =~ /ebs|rhel/i
      true
    else
      false
    end
  end
end

# Represents the Microsoft Azure cloud specific behavior.
#
# @see Cloud
#
class Azure < Cloud
  # Checks if a server can have ephemeral devices.
  #
  # @param server [Server] the server to check for ephemeral support
  #
  # @return [Boolean] whether the cloud supports ephemeral devices
  #
  # @see Cloud#supports_ephemeral?
  #
  def supports_ephemeral?(server)
    true
  end
end

# Represents the Apache CloudStack cloud specific behavior. Datapipe,
# Logicworks, and IDC Frontier are CloudStack clouds.
#
class CloudStack < Cloud
  # Checks if the cloud is configured in a way where SSH must be done to a
  # private IP address from within the cloud.
  #
  # @return [Boolean] whether to SSH to a private IP address within the cloud
  #
  # @see Cloud#needs_private_ssh?
  #
  def needs_private_ssh?
    case @cloud_name
    when /^IDC Frontier /, "Logicworks"
      true
    else
      false
    end
  end
end

# Represents the Openstack cloud specific behavior. HP Cloud and Rackspace
# Private are Openstack clouds.
#
# @see Cloud
#
class Openstack < Cloud
  # Checks if a server can have ephemeral devices.
  #
  # @param server [Server] the server to check for ephemeral support
  #
  # @return [Boolean] whether the cloud supports ephemeral devices
  #
  # @see Cloud#supports_ephemeral?
  #
  def supports_ephemeral?(server)
    true
  end
end
