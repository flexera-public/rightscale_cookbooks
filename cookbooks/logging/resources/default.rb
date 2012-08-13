#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Add actions to @action_list array.
# Used to allow comments between entries.
def self.add_action(sym)
  @action_list ||= Array.new
  @action_list << sym unless @action_list.include?(sym)
  @action_list
end

# = Log Attributes
#
# Below are the attributes defined by the Log resource interface.
#

# == General options

# = General Log Actions
#
# Below are the actions defined by by the Log resource interface.
#

# == Stop
# Stop the logging service.
#
# Calls the logging service stop command
#
add_action :stop

# == Start
# Start the logging service.
#
# Calls the logging service start command
#
add_action :start

# == Restart
# Restart the logging service.
#
# Calls the logging service restart command
#
add_action :restart

# == Reload
# load the logging service.
#
# Calls the logging service load command
#
add_action :reload

# == Status
# Output the status of the logging service.
#
# Log and return the logging service status command results.
#
add_action :status

# == Rotate
#
# Call the logging rotate command
#
add_action :rotate

# == Add logging definition
# Add a logging definition
#
add_action :add_definition

# == Add Log Rotation Policy
#
add_action :add_rotate_policy

# == Install Software
# Installs logging software
#
add_action :install

# == Configure
# Updates the configuration
#
add_action :configure
  attribute :remote_server, :kind_of => String

# == Configure server
# Configures a logging server
#
add_action :configure_server

actions @action_list
