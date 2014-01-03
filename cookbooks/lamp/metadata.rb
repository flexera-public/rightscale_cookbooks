name             "lamp"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "This is a basic all-in-one LAMP (Linux, Apache, MySQL, PHP)" +
                 " cookbook designed to work in a hybrid cloud setting."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.1"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "db_mysql"
depends "app_php"

recipe "lamp::default",
  "Sets up LAMP-specific default attributes."
