maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs the php application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

supports "centos", "~> 5.8"
supports "centos", "~> 6.2"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

depends "app"
depends "web_apache"
depends "db_mysql"
depends "db_postgres"
depends "repo"
depends "rightscale"

recipe  "app_php::default", "Installs the php application server."

attribute "app_php",
  :display_name => "PHP Application Settings",
  :type => "hash"

attribute "app_php/modules_list",
  :display_name => "PHP module packages",
  :description => "An optional list of php module packages to install. Accepts an array of package names. When using CentOS, package names are prefixed with php53u instead of php. To see a list of available php modules on CentOS, run 'yum search php53u' on the server. Example: php53u-mysql, php53u-pecl-memcache",
  :required => "optional",
  :type => "array",
  :recipes => ["app_php::default"]

