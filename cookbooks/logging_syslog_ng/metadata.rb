maintainer "RightScale, Inc."
maintainer_email "support@rightscale.com"
license "Copyright RightScale, Inc. All rights reserved."
description "Provides 'syslog_ng' implementation of the 'logging' resource to" +
  " configure 'syslog_ng' to log to a remote server or use default local file" +
  " logging."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "logging"

recipe "logging_syslog_ng::setup_server",
  "Sets syslog_ng logging provider"
