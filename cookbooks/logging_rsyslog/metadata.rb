maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Enable instance Monitoring in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

depends "logging"

# There is no need to show this, as the base logging cookbook should be used.
#recipe "logging_rsyslog::default", "Set rsyslog logging provider"
