maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Virtual Monkey"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04" 


depends "rightscale"
depends "sys_firewall"
depends "repo"

recipe "monkey::default", "Default recipe for monkey setup."
recipe "monkey::setup_git", "Setting up Git for monkey."
recipe "monkey::setup_rest_connection", "Setting up rest_connection for monkey."
recipe "monkey::setup_virtualmonkey", "Setting up virtualmonkey."
recipe "monkey::test_virtualmonkey_api_connection", "Testing API connectivity for virtualmonkey."
recipe "monkey::setup_rightcloud_private_api", "Setting up rightcloud_private_api gem."

attribute "monkey/git/user",
  :display_name => "Git Username",
  :description => "Git Username to be used with github",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/git/email",
  :display_name => "Git Email",
  :description => "Git email address to be used with github",
  :required => "required",
  :recipes => ["monkey::setup_git"]

