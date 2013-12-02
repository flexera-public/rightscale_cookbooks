name             "lb_clb"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "RightScale load balancer cookbook for Rackspace Cloud Load" +
                 " Balancing (CLB). This cookbook provides recipes for attaching" +
                 " and detaching application servers to and from an existing" +
                 " Rackspace Cloud  Load Balancer (CLB)."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "lb"
