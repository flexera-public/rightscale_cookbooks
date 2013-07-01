maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Provides 'syslog_ng' implementation of the 'logging' resource" +
                 " to configure 'syslog_ng' to log to a remote server or use" +
                 " default local file logging."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "logging"

recipe "logging_syslog_ng::setup_server",
  "Sets syslog_ng logging provider"
