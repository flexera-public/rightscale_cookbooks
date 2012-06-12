maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Enable instance Monitoring in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

depends "rightscale"
depends "logging_rsyslog"
depends "logging_syslog_ng"

recipe "logging::default", "Configures native logging provider"

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
  :description => "The FQDN or IP address of a remote server to configure the instance to forward log data do. Example: syslog.example.com or 192.168.0.1",
  :required => "optional",
  :recipes => [ "logging::default" ]

attribute "logging/remote_port",
  :display_name => "Remote Port",
  :description => "The port on the remote server to configure the instance to forward log data do. Example: 514",
  :required => "optional",
  :recipes => [ "logging::default" ]
