name             "repo_ros"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Provides the Remote Object Store implementation of the 'repo'" +
                 " resource to manage the downloading of source code from" +
                 " Remote Object Store repositories such as Amazon S3," +
                 " Rackspace Cloud Files, and OpenStack Swift."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.1"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "repo"

recipe  "repo_ros::default",
  "Checks for ros_util binary availability"
