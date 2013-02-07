maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Manages the RSYNC code download"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.4.0"

supports "centos", "~> 5.8"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

depends "repo"

recipe  "repo_rsync::default",
  "Installs \"rsync\" package."
