maintainer "RightScale, Inc."
maintainer_email "support@rightscale.com"
license "Copyright RightScale, Inc. All rights reserved."
description "RightScale load balancer cookbook for AWS Elastic Load Balancer" +
  " (ELB). This cookbook provides recipes for attaching and detaching" +
  " application servers to and from an existing AWS Elastic Load Balancer" +
  " (ELB)."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"
depends "lb"
