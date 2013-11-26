maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
name             "ruby"
description      "Installs and configures Ruby"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"

recipe "ruby::install_1_8",
  "Installs and configures Ruby 1.8."

recipe "ruby::install_1_9",
  "Installs and configures Ruby 1.9."
