maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures lb_haproxy"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"

depends "rs_tools"
depends "rightscale"
depends "app"
depends "lb"

recipe "lb_haproxy::default", "This loads the required 'lb' resource using the HAProxy provider."
