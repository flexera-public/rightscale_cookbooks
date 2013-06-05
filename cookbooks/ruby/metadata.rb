maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures Ruby"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

recipe "ruby::install_1_8",
  "Installs and configures Ruby 1.8."

recipe "ruby::install_1_9",
  "Installs and configures Ruby 1.9."
