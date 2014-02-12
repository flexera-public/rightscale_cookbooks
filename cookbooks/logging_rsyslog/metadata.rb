maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Provides 'rsyslog' implementation of the 'logging' resource" +
                 " to configure 'rsyslog' to log to a remote server or use" +
                 " default local file logging."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "logging"

recipe "logging_rsyslog::setup_server",
  "Sets rsyslog logging provider"
