maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Adds application servers to ELB"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

{'centos' => '>= 5.8', 'ubuntu' => '>= 10.04', 'redhat' => '>= 5.8'}.each_pair {|os, version| supports os , version}

depends "rightscale"
depends "lb"
