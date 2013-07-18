maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures rs-postfix"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "postfix"

recipe "rs-postfix::setup_local_delivery",
  "Configures postfix to deliver local mail by accepting SMTP connections" +
  " on localhost."
