maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Enable instance Monitoring in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.3.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "logging"

recipe "logging_syslog_ng::default",
  "Set syslog_ng logging provider"
