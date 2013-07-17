maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures rs-postfix"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "postfix"

recipe "rs-postfix::default",
  "Default recipe in wrapper cookbook of postfix. Logic is done here based on" +
  " inputs to determine which recipe in postfix cookbook to run."

attribute "postfix/mail_type",
  :display_name => "Postfix Mail Type",
  :description => "Is this node a client or server/master?",
  :required => "optional",
  :choice => ["client", "master"],
  :default => "master",
  :recipes => ["rs-postfix::default"]

attribute "postfix/myhostname",
  :display_name => "Postfix Myhostname",
  :description => "Sets the myhostname value in main.cf",
  :required => "optional",
  :default => "fqdn",
  :recipes => ["rs-postfix::default"]

attribute "postfix/mydomain",
  :display_name => "Postfix Mydomain",
  :description => "Sets the mydomain value in main.cf",
  :required => "optional",
  :default => "domain",
  :recipes => ["rs-postfix::default"]

attribute "postfix/myorigin",
  :display_name => "Postfix Myorigin",
  :description => "Sets the myorigin value in main.cf",
  :required => "optional",
  :default => "fqdn",
  :recipes => ["rs-postfix::default"]

attribute "postfix/relayhost",
  :display_name => "Postfix Relayhost",
  :description => "Sets the relayhost value in main.cf",
  :required => "optional",
  :default => "",
  :recipes => ["rs-postfix::default"]

attribute "postfix/mail_relay_networks",
  :display_name => "Postfix Mail Relay Networks",
  :description => "Sets the mynetworks value in main.cf",
  :required => "optional",
  :default => "127.0.0.0/8",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_sasl_auth_enable",
  :display_name => "Postfix SMTP SASL Auth Enable",
  :description => "Enable SMTP SASL Authentication",
  :required => "optional",
  :choice => ["no", "yes"],
  :default => "no",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_sasl_password_maps",
  :display_name => "Postfix SMTP SASL Password Maps",
  :description => "hashmap of SASL passwords",
  :required => "optional",
  :default => "hash:/etc/postfix/sasl_passwd",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_sasl_security_options",
  :display_name => "Postfix SMTP SASL Security Options",
  :description => "Sets the value of smtp_sasl_security_options in main.cf",
  :required => "optional",
  :default => "noanonymous",
  :recipes => ["rs-postfix::default"]

attribute "postfix/inet_interfaces",
  :display_name => "Postfix listening interfaces",
  :description => "Interfaces to listen to, all or loopback-only." +
    " Default is all for master mail_type, and loopback-only otherwise",
  :required => "optional",
  :default => "all",
  :choice => ["all", "loopback-only"],
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_tls_cafile",
  :display_name => "Postfix SMTP TLS CA File",
  :description => "CA certificate file for SMTP over TLS",
  :required => "optional",
  :default => "/etc/postfix/cacert.pem",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_use_tls",
  :display_name => "Postfix SMTP Use TLS?",
  :description => "Whether SMTP SASL Auth should use TLS encryption",
  :required => "optional",
  :choice => ["no", "yes"],
  :default => "yes",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_sasl_user_name",
  :display_name => "Postfix SMTP SASL Username",
  :description => "User to auth SMTP via SASL",
  :required => "optional",
  :default => "",
  :recipes => ["rs-postfix::default"]

attribute "postfix/smtp_sasl_passwd",
  :display_name => "Postfix SMTP SASL Password",
  :description => "Password for smtp_sasl_user_name",
  :required => "optional",
  :default => "",
  :recipes => ["rs-postfix::default"]
