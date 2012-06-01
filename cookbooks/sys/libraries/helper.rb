#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module System
    module Helper

      # Calculates every 15 minute schedule for cron minute setting
      # Uses a random start offset to avoid all systems from reconverging at the same time.
      #
      # @return [String] randomized schedule time
      def self.randomize_reconverge_minutes
        shed_string = ""
        s = rand(15) # Get random start minute
        4.times do |q|
          shed_string << "," unless q == 0
          shed_string << "#{s + (q*15)}"
        end
        shed_string.strip
      end

      # Use the server_collection resource programatically
      def self.requery_server_collection(tag, collection_name, node, run_context)
        resrc = Chef::Resource::ServerCollection.new(collection_name)
        resrc.tags tag
        provider = nil
        provider = Chef::Provider::ServerCollection.new(resrc, run_context)
        provider.send("action_load")
      end

      # Use the template resource programatically
      def self.run_template(target_file, source, cookbook, variables, enable, command, node, run_context)
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

        Chef::Log.info `/usr/sbin/rebuild-iptables` if resrc.updated
      end

      def self.calculate_exponential_backoff(value)
        ((value == 1) ? 2 : (value*value))
      end

    end
  end
end
