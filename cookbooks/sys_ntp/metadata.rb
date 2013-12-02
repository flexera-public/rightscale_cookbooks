name             "sys_ntp"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "This cookbook provides a recipe for setting up time" +
                 " synchronization using NTP."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"

recipe "sys_ntp::default",
  "Installs and configures ntp client."

attribute "sys_ntp/servers",
  :display_name => "NTP Servers",
  :description =>
    "A comma-separated list of fully qualified domain names " +
    " for the array of servers that instances should talk to. " +
    " Example: time1.example.com, time2.example.com, time3.example.com",
  :type => "string",
  :default => "time.rightscale.com, ec2-us-east.time.rightscale.com, " +
    "ec2-us-west.time.rightscale.com"
