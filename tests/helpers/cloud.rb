# Cloud base class.
class Cloud
  extend VirtualMonkey::TestCase::Mixin

  # Factory method that returns an instance of the right cloud class based on the +:cloud+ variable.
  #
  # @return [Cloud] Cloud base object.
  def self.factory
    case get_cloud_name
    when /^AWS /
      EC2.new
    else
      Cloud.new
    end
  end

  # States that non-EC2 clouds do not support start/stop operations.
  #
  # @return [Boolean] False.
  def supports_start_stop?(server)
    false
  end
end

# EC2 cloud class.
class EC2 < Cloud
  # Overrides base function.
  # Checks if EC2 server supports start/stop operations.
  # Only supported on EBS images.
  #
  # @return [Boolean] True if EBS image and False otherwise.
  def supports_start_stop?(server)
    # Only EC2 EBS images support start/stop operations.
    mci_data = get_server_metadata(server)
    # All RHEL images are EBS, but may not say so.
    if (mci_data[:mci_name].to_s.downcase =~ /ebs|rhel/)
      true
    else
      false
    end
  end

  # XXX: stub get_server_metadata
  def get_server_metadata(server)
    {:mci_name => "RightImage_CentOS_6.3_x64_v5.8_STAGING"}
  end
end
