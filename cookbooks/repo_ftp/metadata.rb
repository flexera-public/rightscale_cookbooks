maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
name             "repo_ftp"
description      "Provides the FTP implementation of the 'repo' resource to" +
                 " manage source code downloaded from FTP."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "repo"

recipe  "repo_ftp::default",
  "Installs \"wget\" package."
