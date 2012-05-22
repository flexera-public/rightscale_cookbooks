#
# Cookbook Name:: sys_dns
#
# Copyright RightScale, Inc. All rights reserved.  All access and use subject to the
# RightScale Terms of Service available at http://www.rightscale.com/terms.php and,
# if applicable, other agreements such as a RightScale Master Subscription Agreement.

actions :set_private

attribute :id, :kind_of => String
attribute :user, :kind_of => String
attribute :password, :kind_of => String
attribute :address, :kind_of => String, :regex => /^(\d{1,3}).(\d{1,3}).(\d{1,3}).(\d{1,3})=.+/
attribute :region, :kind_of => String   # this is used by CloudDNS
attribute :choice, :equal_to => [ "DNSMadeEasy", "DynDNS", "Route53", "CloudDNS" ]
