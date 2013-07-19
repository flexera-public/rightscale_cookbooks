#
# Cookbook Name:: rightscale
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

rightscale_marker

# Installs all extra packages RightImages have installed by default.  Use 
# this recipe to ensure non-RightImages have the packages our ServerTemplates
# require.

package "rightimage-extras"
