#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

module RightScale
  module Utils
    module Helper
      NAMESPACE_REGEX = '[a-z](?:[a-z0-9_]*)'
      PREDICATE_REGEX = '[a-zA-Z0-9%_\+\.-](?:[a-zA-Z0-9%_\+\.-]*)'
      # The following regex matches valid IP addresses. It is obtained from
      # http://www.regular-expressions.info/examples.html
      IPADDRESS_REGEX = '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'

      # Determines if a tag matches a given wildcard expression or prefix.
      #
      # @param [String] wildcard expression or prefix
      # @param [String] tag
      #
      # @return [Boolean] True if the tag matches the wildcard expression or prefix, false otherwise
      def self.matches_tag_wildcard?(wildcard, tag)
        if wildcard =~ /^(#{NAMESPACE_REGEX}):$/
          wildcard = "#{$1}:*"
        elsif wildcard =~ /^(#{NAMESPACE_REGEX}):(#{PREDICATE_REGEX})=?$/
          wildcard = "#{$1}:#{$2}=*"
        end

        File.fnmatch?(wildcard, tag)
      end

      # Filters a server collection to only include servers with all of the supplied tags.
      #
      # @param [Chef::Node::Attribute] collection dictionary of server collections
      # @param [String] name name of the server collection to filter
      # @param [Array] tags list of tags or tag wildcards to filter by
      #
      # @return [Hash] A filtered server collection
      def self.filter_tags(collection, name, tags)
        collection[name].reject do |key, values|
          reject = false

          tags.each do |tag|
            break reject = true if values.select { |value| File.fnmatch?(tag, value) }.empty?
          end

          reject
        end.to_hash
      end

      # Filters a server collection to only include servers with all of the supplied tags modifying the given server collection.
      #
      # @param [Chef::Node::Attribute] collection dictionary of server collections
      # @param [String] name name of the server collection to filter
      # @param [Array] tags list of tags or tag wildcards to filter by
      #
      # @return [Hash] A filtered server collection
      def self.filter_tags!(collection, name, tags)
        collection[name] = filter_tags(collection, name, tags)
      end

      # Get the value portion of a tag with a given prefix from a list of tags.
      #
      # @param [String] prefix the prefix of tag to retrieve
      # @param [Array] tags list of tags to search
      # @param [String] capture optional Regexp portion to validate the value
      #
      # @return [String] The value portion of a tag if found, nil if not found or value is invalid
      def self.get_tag_value(prefix, tags, capture = '.*')
        if tags.detect { |tag| tag =~ /^#{Regexp.escape(prefix)}=(#{capture})$/ }
          $1
        end
      end

      # Returns true if a valid IP address is give and false if it is invalid
      #
      # @param [String] ip IP addres
      #
      # @return [Boolean] True if the IP address is valid and false if it is
      #   invalid
      def self.is_valid_ip?(ip)
        ip =~ /^#{IPADDRESS_REGEX}$/
      end

      # Returns true of the cloud is a rackspace managed cloud and false
      # otherwise
      #
      # @return [Boolean] True if the cloud is a rackspace managed cloud and
      #   false otherwise
      #
      def self.is_rackspace_managed_cloud?
        xenstore_ls = Mixlib::ShellOut.new("xenstore-ls vm-data")
        xenstore_ls.run_command
        xenstore_ls.error!

        # Check for the role "rax_managed". This role will only be set on a
        # Rackspace Managed Cloud.
        matched_data = xenstore_ls.stdout.match(/roles = (.*)/)
        !matched_data.nil? && matched_data[1].include?("rax_managed")
      end

      # Obtains the rackspace region name
      #
      # @return [String] rackspace region name
      #
      def self.get_rackspace_region
        xenstore_ls = Mixlib::ShellOut.new("xenstore-ls vm-data")
        xenstore_ls.run_command
        xenstore_ls.error!

        # Obtain the region from the xenstore.
        region = ""
        matched_data = xenstore_ls.stdout.match(/region = \"(.*)\"/)
        region = matched_data[1] unless matched_data.nil?
        region
      end
    end
  end
end
