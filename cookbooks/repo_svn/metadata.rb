maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Manages the Subversion version control system"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"


supports "centos", "< 6.0"
supports "centos", ">= 5.8"

supports "redhat", "< 6.0"
supports "redhat", ">= 5.8"

supports "ubuntu", "= 10.04"


depends "repo"

recipe  "repo_svn::default", "Default pattern of loading packages and resources provided"
