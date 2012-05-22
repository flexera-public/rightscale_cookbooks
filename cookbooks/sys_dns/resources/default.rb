#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

# Used to pass data to the helper file and call the corresponding dns provider
#  :id - The unique identifier that is associated with the DNS A record of the server.
#  :user - The user name that is used to access and modify your DNS A records.
#  :password - The password that is used to access and modify your DNS A records.
#  :address - Private IP of instance running the recipe.
#  :region< - CloudDNS specific: region where the A records should be modified.
#  :choice - One of the supported DNS providers: "DNSMadeEasy" / "DynDNS" / "Route53" / "CloudDNS"

actions :set_private

attribute :id, :kind_of => String
attribute :user, :kind_of => String
attribute :password, :kind_of => String
attribute :address, :kind_of => String, :regex => /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})/
attribute :region, :kind_of => String
attribute :choice, :equal_to => [ "DNSMadeEasy", "DynDNS", "Route53", "CloudDNS" ]
