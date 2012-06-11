maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures lamp"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

{'centos' => '>= 5.8', 'ubuntu' => '>= 10.04', 'redhat' => '>= 5.8'}.each_pair {|os, version| supports os , version}

depends "db_mysql"
depends "app_php"

recipe "lamp::default", "Install LAMP specific packages. Setup LAMP specific default attributes"
