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

      # Determines if a tag matches a given wildcard expression or prefix.
      #
      # @param wildcard [String] expression or prefix
      # @param tag [String]
      #
      # @return [Boolean] True if the tag matches the wildcard expression or prefix, false otherwise
      def self.matches_tag_wildcard?(wildcard, tag)
        if wildcard =~ /^(#{NAMESPACE_REGEX}):$/
          wildcard = "#{$1}:*"
        elsif wildcard =~ /^(#{NAMESPACE_REGEX}):(#{PREDICATE_REGEX})=?$/
          wildcard = "#{$1}:#{$2}=*"
        end

        File.fnmatch?(wildcard, tag)
      end # def self.matches_tag_wildcard?(wildcard, tag)

      # Filters a server collection to only include servers with all of the supplied tags.
      #
      # @param collection [Chef::Node::Attribute] dictionary of server collections
      # @param name [String] name of the server collection to filter
      # @param tags [Array] list of tags or tag wildcards to filter by
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
      end # def self.filter_tags(collection, name, tags)

      # Filters a server collection to only include servers with all of the supplied tags modifying the given server collection.
      #
      # @param collection [Chef::Node::Attribute] dictionary of server collections
      # @param name [String] name of the server collection to filter
      # @param tags [Array] list of tags or tag wildcards to filter by
      #
      # @return [Hash] A filtered server collection
      def self.filter_tags!(collection, name, tags)
        collection[name] = filter_tags(collection, name, tags)
      end # def self.filter_tags!(collection, name, tags)

      # Get the value portion of a tag with a given prefix from a list of tags.
      #
      # @param prefix [String] the prefix of tag to retrieve
      # @param tags [Array] list of tags to search
      # @param capture [String] optional Regexp portion to validate the value
      #
      # @return [String] The value portion of a tag if found, nil if not found or value is invalid
      def self.get_tag_value(prefix, tags, capture = '.*')
        if tags.detect { |tag| tag =~ /^#{Regexp.escape(prefix)}=(#{capture})$/ }
          $1
        end
      end # def self.get_tag_value(prefix, tags, capture = '.*')

    end
  end
end
