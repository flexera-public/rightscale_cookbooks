maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures lamp"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

depends "db_mysql"
depends "app_php"

recipe "lamp::default", "Install LAMP specific packages. Setup LAMP specific default attributes"
