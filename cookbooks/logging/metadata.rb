maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Enable instance Monitoring in the RightScale dashboard."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.3.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"

depends "rightscale"
depends "logging_rsyslog"
depends "logging_syslog_ng"

recipe "logging::default",
  "Default recipe to setup provided resources."

recipe "logging::install_server",
  "Configures a logging server."

recipe "logging::do_server_start",
  "Starts logging server."

recipe "logging::do_server_stop",
  "Stops logging server."

recipe "logging::do_server_restart",
  "Restarts logging server."

recipe "logging::do_server_reload",
  "Reloads logging server."

attribute "logging",
  :display_name => "Log Service Settings",
  :type => "hash"

attribute "logging/remote_server",
  :display_name => "Remote Server",
  :description =>
    "Configures an instance to forward its log data to a remote server." +
    " Specify either the remote server's FQDN or IP address." +
    " Example: syslog.example.com or 192.168.0.1",
  :required => "optional",
  :recipes => ["logging::default"]

attribute "logging/protocol",
  :display_name => "Logging Protocol",
  :description =>
    "Protocol used to send logging messages from client to server." +
    " Example: udp",
  :required => "optional",
  :choice => ["udp", "relp", "relp-secured"],
  :default => "udp",
  :recipes => [
    "logging::default",
    "logging::install_server"
  ]

attribute "logging/certificate",
  :display_name => "SSL Certificate",
  :description =>
    "Specify the SSL Certificate to enable authentication with stunnel." +
    " Should contain both certificate and key. Certificate should be" +
    " provided for both the Clients and the Logging Server." +
    " Example: cred:LOGGING_SSL_CRED",
  :required => "optional",
  :recipes => [
    "logging::default",
    "logging::install_server"
  ]
