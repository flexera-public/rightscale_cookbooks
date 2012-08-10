maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Adds application servers to ELB"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

supports "centos", "~> 5.8"
supports "centos", "~> 6.2"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

depends "rightscale"
depends "lb"
