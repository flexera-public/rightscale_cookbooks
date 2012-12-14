#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

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
actions :stop

# == Start
# Start the logging service.
#
# Calls the logging service start command
#
actions :start

# == Restart
# Restart the logging service.
#
# Calls the logging service restart command
#
actions :restart

# == Reload
# load the logging service.
#
# Calls the logging service load command
#
actions :reload

# == Status
# Output the status of the logging service.
#
# Log and return the logging service status command results.
#
actions :status

# == Rotate
#
# Call the logging rotate command
#
actions :rotate

# == Add logging definition
# Add a logging definition
#
actions :add_definition

# == Add Log Rotation Policy
#
actions :add_rotate_policy

# == Install Software
# Installs logging software
#
actions :install

# == Configure
# Updates the configuration
#
actions :configure
  attribute :remote_server, :kind_of => String

# == Configure server
# Configures a logging server
#
actions :configure_server
