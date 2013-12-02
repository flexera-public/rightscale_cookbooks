name             "app_php"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Cookbook provides Apache + PHP implementation of the 'app'" +
                 " LWRP. Installs and configures, Apache + PHP application server."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "app"
depends "repo"
depends "rightscale"
depends "web_apache"

recipe "app_php::setup_server_5_3",
  "Installs the php application server."

attribute "app_php",
  :display_name => "PHP Application Settings",
  :type => "hash"

attribute "app_php/modules_list",
  :display_name => "PHP module packages",
  :description =>
    "An optional list of php module packages to install. Accepts an array" +
    " of package names. When using CentOS, package names are prefixed with" +
    " php53u instead of php. To see a list of available php modules on" +
    " CentOS, run 'yum search php53u' on the server." +
    " Example: php53u-mysql, php53u-pecl-memcache",
  :required => "optional",
  :type => "array",
  :recipes => ["app_php::setup_server_5_3"]
