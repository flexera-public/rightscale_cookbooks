#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Actions supported by this resource

# Enables cookbook reconverge
actions :enable

# Disables cookbook reconverge
actions :disable

# Name of the recipe
attribute :recipe_name, :kind_of => String, :regex => /[A-Za-z0-9_-]+::[A-Za-z0-9_-]+/

# Interval in minutes
attribute :interval, :kind_of => Integer

# Defines a default action
def initialize(*args)
  super
  @action = :enable
end
