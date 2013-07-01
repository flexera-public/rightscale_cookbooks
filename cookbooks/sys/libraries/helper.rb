#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

module RightScale
  module System
    module Helper

      # Calculates schedule for cron minute based on user provided
      # interval. Uses a random start offset from given splay
      # to avoid all systems from reconverging at the same time.
      #
      # @param interval [Integer] interval for reconverge
      # @param splay [Integer] random number maximum limit
      #
      # @return [String] randomized schedule time
      #
      # @raise [RuntimeError] if interval parameter is not between 0 and 60
      #
      def self.randomize_reconverge_minutes(interval, splay)
        # Check parameters
        err = ArgumentError.new("ERROR: reconverge interval must be between" +
          " > 0 and < 60 minutes. You requested '#{interval}'.")
        raise err if interval > 60 || interval <= 0

        # Calculate random start minute offset
        offset = rand(splay)

        # Create cron minute schedule string
        shed = []
        (60/interval).times do |q|
          min = (offset + (q*interval)) % 60
          shed << min
        end
        shed.sort! * ","
      end

      # Use the server_collection resource programatically
      #
      # @param tag [String] tag name
      # @param collection_name [String] Server collection name
      # @param node [Hash] node
      # @param run_context [String] run context for the ServerCollection provider
      #
      def self.requery_server_collection(tag, collection_name, node, run_context)
        resrc = Chef::Resource::ServerCollection.new(collection_name)
        resrc.tags tag
        provider = nil
        provider = Chef::Provider::ServerCollection.new(resrc, run_context)
        provider.send("action_load")
      end

      # Use the template resource programatically
      #
      # @param target_file [String] target file to be created from the template
      # @param source [String] source erb file
      # @param cookbook [String] name of the cookbook
      # @param variables [Hash] variables to be passed to the template resource
      # @param enable [Boolean] whether to enable the template or disable it
      # @param command [String] command to run if the template is updated
      # @param node [Hash] chef node
      # @param run_context [Chef::RunContext] chef's run context
      #
      # @return [Boolean] whether the target file is updated
      #
      def self.run_template(target_file, source, cookbook, variables, enable,
        command, node, run_context)
        resrc = Chef::Resource::Template.new(target_file)
        resrc.source source
        resrc.cookbook cookbook
        resrc.variables variables
        resrc.backup false
        #resrc.notifies notify_action, notify_resources

        provider = Chef::Provider::Template.new(resrc, run_context)
        provider.load_current_resource

        if enable
          provider.send("action_create")
        else
          provider.send("action_delete")
        end

        if resrc.updated
          shell_command = Mixlib::ShellOut.new(command)
          shell_command.run_command
          shell_command.error!

          Chef::Log.info shell_command.stdout
        end
        resrc.updated
      end

      # Calculate exponential delay for a given number.
      #
      # @param value [Integer] delay value
      #
      # @return [Integer] exponential value
      #
      def self.calculate_exponential_backoff(value)
        ((value == 1) ? 2 : (value*value))
      end

      # Reload sysctl
      #
      def self.reload_sysctl
        reload_command = Mixlib::ShellOut.new(
          "/sbin/sysctl -e -p /etc/sysctl.conf"
        )
        reload_command.run_command
        reload_command.error!
        Chef::Log.info reload_command.stdout
      end
    end
  end
end
