maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs and configures rs-postfix"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

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
