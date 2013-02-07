maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures lamp"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "db_mysql"
depends "app_php"

recipe "lamp::default",
  "Sets up LAMP-specific default attributes."
