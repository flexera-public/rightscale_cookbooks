maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Manages the RSYNC code download"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "repo"

recipe  "repo_rsync::default",
  "Installs \"rsync\" package."
