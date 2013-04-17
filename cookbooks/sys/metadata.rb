maintainer "RightScale, Inc."
maintainer_email "support@rightscale.com"
license "Copyright RightScale, Inc. All rights reserved."
description "Provides RightScale system utilities."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version "13.4.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"

recipe "sys::do_reconverge_list_enable",
  "Enables the periodic execution (every 15 minutes) of recipes specified" +
  " in the 'Reconverge List' input."

recipe "sys::do_reconverge_list_disable",
  "Disables recipe reconverge list."

recipe "sys::setup_swap",
  "Installs swap space."

attribute "sys/reconverge_list",
  :display_name => "Reconverge List",
  :description =>
    "A space-separated list of recipes to run every 15 minutes," +
    " which is designed to enforce system consistency." +
    " Example: app::do_firewall_request_open lb_haproxy::do_attach_all",
  :required => "optional",
  :default => "",
  :recipes => [
    "sys::default",
    "sys::do_reconverge_list_enable",
    "sys::do_reconverge_list_disable"
  ]

attribute "sys/swap_size",
  :display_name => "Swap size in GB",
  :description =>
    "Creates and activates a swap file based on the selected size (in GB)." +
    " Note: The swap added by this file will be in addition to" +
    " any swap defined in the image. Example: 1.0",
  :type => "string",
  :choice => ["0.5", "1.0", "2.0"],
  :default => "0.5",
  :recipes => [
    "sys::setup_swap"
  ]

attribute "sys/swap_file",
  :display_name => "Swapfile location",
  :description =>
    "The location of the swap file. Example: /mnt/ephemeral/swapfile",
  :type => "string",
  :default => "/mnt/ephemeral/swapfile",
  :recipes => [
    "sys::setup_swap"
  ]
