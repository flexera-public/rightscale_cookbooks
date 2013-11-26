maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
name             "repo_git"
description      "Provides the Git implementation of the 'repo' resource to" +
                 " manage source code download from Git repositories."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "git"
depends "repo"

recipe  "repo_git::default",
  "Installs \"git\" package."
