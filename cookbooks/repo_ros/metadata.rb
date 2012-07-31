maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Manages the ROS repo code download"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

depends "repo"

recipe  "repo_ros::default", "Default pattern for loading provided packages and resources."
