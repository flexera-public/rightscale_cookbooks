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

attribute "monkey/git/ssh_key",
  :display_name => "SSH key for Git",
  :description => "SSH key for using with Git",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/git/host_name",
  :display_name => "Git Hostname",
  :description => "Git Hostname for adding to ssh config",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/rest/right_passwd",
  :display_name => "RightScale password",
  :description => "RightScale password to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/right_email",
  :display_name => "RightScale Email",
  :description => "RightScale email address to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/right_acct_id",
  :display_name => "RightScale account ID",
  :description => "RightScale account ID used to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/ssh_key",
  :display_name => "API user key",
  :description => "API user key used by rest_connection",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/repo_url",
  :display_name => "Rest connection Repo URL",
  :description => "Git URL for checking out rest_connection project",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/virtualmonkey/monkey_repo_url",
  :display_name => "VirtualMonkey Repo URL",
  :description => "Git repository URL for VirtualMonkey",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/collateral_repo_url",
  :display_name => "Collateral Repo URL",
  :description => "Git URL for collateral project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/environment",
  :display_name => "VirtualMonkey Environment",
  :description => "VirtualMonkey Environmnet",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

