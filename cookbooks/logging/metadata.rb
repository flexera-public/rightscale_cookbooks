maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Enable instance Monitoring in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"
depends "logging_rsyslog"
depends "logging_syslog_ng"

recipe "logging::default", "Configures a native logging provider."
recipe "logging::install_server", "Configures a syslog server."
recipe "logging::do_server_start", "Starts syslog server."
recipe "logging::do_server_stop", "Stops syslog server."
recipe "logging::do_server_restart", "Restarts syslog server."
recipe "logging::do_server_reload", "Reloads syslog server."

attribute "logging",
  :display_name => "Log Service Settings",
  :type => "hash"

# Provider is used to select the logging package to use.  It is not needed unless replacing
# rsyslog with syslog-ng
#attribute "logging/provider",
#  :display_name => "Logging Service Provider",
#  :description => "The logging service client to use on the server. (logging_rsyslog or logging_syslog_ng)",
#  :required => "optional",
#  :choice => [ "logging_rsyslog", "logging_syslog_ng" ],
#  :default => "logging_syslog_ng",
#  :recipes => [ "logging::do_install" ]

attribute "logging/remote_server",
  :display_name => "Remote Server",
  :description => "Configures an instance to forward its log data to a remote server. Specify either the remote server's FQDN or IP address. Example: syslog.example.com or 192.168.0.1",
  :required => "optional",
  :recipes => [ "logging::default" ]

attribute "logging/service_action",
  :display_name => "Logging Service Control Action",
  :description => "Action to be done with logging service.",
  :required => "optional",
  :choice => [ "start", "stop", "restart", "reload" ],
  :recipes => [ "logging::service_control" ]

attribute "logging/protocol",
  :display_name => "Logging Protocol",
  :description => "Protocol used to send logging messages from client to server.",
  :required => "optional",
  :choice => [ "udp", "tcp", "relp", "relp+stunnel" ],
  :default =>  "udp",
  :recipes => [
    "logging::default",
    "logging::install_server"
  ]
