#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# The server collection resource finds a set of servers in a deployment with a set of tags.
actions :load
#
# Attribute specifies the tag or tags to search for (if multiple tags are specified servers with any of the tags will match).
attribute :tags, :kind_of => [String, Array]
# Optional attribute specifies tags that need to also appear on the servers.
attribute :secondary_tags, :kind_of => [String, Array]
# IDs for the servers to lookup.
attribute :agent_ids, :kind_of => [String, Array]
# Acceptable timeout on the lookup operation.
attribute :timeout, :default => 60, :kind_of => Integer
attribute :empty_ok, :default => true, :equal_to => [true, false]

# Defines a default action
def initialize(*args)
  super
  @action = :load
end
