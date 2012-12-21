# Cloud base class.
class Cloud
  # Factory method that returns an instance of the right cloud class based on the :cloud variable.
  def self.factory
    case test_variables[:cloud]
    when "EC2"
      EC2.new
    else
      Cloud.new
    end
  end

  def supports_start_stop?(server)
    false
  end
end

# EC2 cloud class.
class EC2 < Cloud
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
end
