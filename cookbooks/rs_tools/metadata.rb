maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/configures RightScale premium tools"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.12"

depends "rs_utils"

provides "rs_tools(:name)"

recipe "rs_tools::default", "Installs RightScale Premium Resources gem and dependencies."
