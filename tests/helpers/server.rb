# Gets the array of Logging servers in the deployment.
#
# @return [Array] an Array of ServerInterfaces of Logging servers
#
# @raise [SelectSetError] if no Logging servers found
#
def logging_servers
  result = select_set(/Logging/)
  raise SelectSetError, "No Logging servers found." unless result.length > 0
  result
end

# Gets the array of Base servers in the deployment.
#
# @return [Array] an Array of ServerInterfaces of Base servers
#
# @raise [SelectSetError] if no Base servers found
#
def base_servers
  result = select_set(/Base/)
  raise SelectSetError, "No Base servers found." unless result.length > 0
  result
end
