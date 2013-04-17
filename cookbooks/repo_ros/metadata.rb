maintainer "RightScale, Inc."
maintainer_email "support@rightscale.com"
license "Copyright RightScale, Inc. All rights reserved."
description "Provides the Remote Object Store implementation of the 'repo'" +
  " resource to manage the downloading of source code from Remote Object" +
  " Store repositories such as Amazon S3, Rackspace Cloud Files, and" +
  " OpenStack Swift."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "repo"

recipe  "repo_ros::default",
  "Checks for ros_util binary availability"
