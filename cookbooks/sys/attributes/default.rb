#
# Cookbook Name:: sys
#
# Copyright RightScale, Inc. All rights reserved.
# All access and use subject to the RightScale Terms of Service available at
# http://www.rightscale.com/terms.php and, if applicable, other agreements
# such as a RightScale Master Subscription Agreement.

# Optional attributes

# Swap size in GB
default[:sys][:swap_size] = "0.5"
# Swap file location
default[:sys][:swap_file] = "/mnt/ephemeral/swapfile"
