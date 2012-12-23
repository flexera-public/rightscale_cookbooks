#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Used to pass data to the helper file and call the corresponding dns provider
actions :set
#
# The unique identifier that is associated with the DNS A record of the server.
attribute :id, :kind_of => String
# The user name that is used to access and modify your DNS A records.
attribute :user, :kind_of => String
# The password that is used to access and modify your DNS A records.
attribute :password, :kind_of => String
# Private IP of instance running the recipe.
attribute :address, :kind_of => String, :regex => /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/ # Verify IP is passed
# CloudDNS specific: region where the A records should be modified.
attribute :region, :kind_of => String
# One of the supported DNS providers: "DNSMadeEasy", "DynDNS", "Route53", or "CloudDNS"
attribute :choice, :equal_to => [ "DNSMadeEasy", "DynDNS", "Route53", "CloudDNS" ]
