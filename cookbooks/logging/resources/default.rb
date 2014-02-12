#
# Cookbook Name:: logging
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# This lightweight resource only defines the interface for logging providers.  This file
# defines the actions and attributes that make up the logging interface (or abstraction).
# See the action details found in the lightweight providers of other implementing
# cookbooks, such as, cookbooks/logging_rsyslog/providers/default.rb

# = Log Attributes
#
# Below are the attributes defined by the Log resource interface.
#

# == General options

# = General Log Actions
#
# Below are the actions defined by by the Log resource interface.
#

# Stops the logging service. Calls the logging service stop command.
actions :stop

# Starts the logging service. Calls the logging service start command.
actions :start

# Restarts the logging service. Calls the logging service restart command.
actions :restart

# Reloads the logging service. Calls the logging service reload command.
actions :reload

# Outputs the status of the logging service. Logs and returns the logging
# service status command results.
actions :status

# Calls the logging rotation command.
actions :rotate

# Adds a logging definition.
actions :add_definition

# Adds log rotation Policy.
actions :add_rotate_policy

# Installs logging software.
actions :install

# Updates the configuration.
actions :configure

  # Remote logging server
  attribute :remote_server, :kind_of => String, :default => ""

# Configures a logging server
actions :configure_server
