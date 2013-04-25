maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Virtual Monkey"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.2.0"

# supports "centos", "~> 5.8", "~> 6"
# supports "redhat", "~> 5.8"
# supports "ubuntu", "~> 10.04", "~> 12.04"


depends "rightscale"

recipe "monkey::default", "Default recipe for monkey setup."
recipe "monkey::setup_git", "Setting up Git for monkey."
recipe "monkey::setup_ruby", "Removing Ruby 1.9 and installing Ruby 1.8."
recipe "monkey::setup_rest_connection", "Setting up rest_connection for monkey."
recipe "monkey::setup_virtualmonkey", "Setting up virtualmonkey."
recipe "monkey::setup_rocketmonkey", "Setting up rocketmonkey."
recipe "monkey::update_fog_credentials", "Setting up or updating existing credentials for fog configuration."
recipe "monkey::test_virtualmonkey_api_connection", "Testing API connectivity for virtualmonkey."

attribute "monkey/fog/aws_access_key_id",
  :display_name => "AWS_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_secret_access_key",
  :display_name => "AWS_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_publish_key",
  :display_name => "AWS_PUBLISH_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_publish_secret_key",
  :display_name => "AWS_PUBLISH_SECRET_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_access_key_id_test",
  :display_name => "AWS_ACCESS_KEY_ID_TEST_ACCT",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_secret_access_key_test",
  :display_name => "AWS_SECRET_ACCESS_KEY_TEST_ACCT",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_api_key",
  :display_name => "RACKSPACE_API_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_username",
  :display_name => "RACKSPACE_USERNAME",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_api_uk_key_test",
  :display_name => "RACKSPACE_API_UK_KEY_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_uk_username_test",
  :display_name => "RACKSPACE_UK_USERNAME_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_access_key_id_rstemp",
  :display_name => "AWS_ACCESS_KEY_ID_RSTEMP",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/aws_secret_access_key_rstemp",
  :display_name => "AWS_SECRET_ACCESS_KEY_RSTEMP",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/softlayer_api_key",
  :display_name => "SOFTLAYER_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/softlayer_username",
  :display_name => "SOFTLAYER_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_managed_auth_key",
  :display_name => "RACKSPACE_MANAGED_AUTH_KEY_US_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_managed_username",
  :display_name => "RACKSPACE_MANAGED_USERNAME_US_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_managed_uk_auth_key",
  :display_name => "RACKSPACE_MANAGED_AUTH_KEY_UK_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_managed_uk_username",
  :display_name => "RACKSPACE_MANAGED_USERNAME_UK_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/rackspace_auth_url_uk_test",
  :display_name => "RACKSPACE_AUTH_URL_UK_TEST",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/google_access_key_id",
  :display_name => "GC_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/google_secret_access_key",
  :display_name => "GC_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/azure_access_key_id",
  :display_name => "AZURE_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/azure_secret_access_key",
  :display_name => "AZURE_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/s3_bucket",
  :display_name => "S3_BUCKET_NAME",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/openstack_access_key_id",
  :display_name => "OPENSTACK_FOLSOM_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/openstack_secret_access_key",
  :display_name => "OPENSTACK_FOLSOM_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/openstack_auth_url",
  :display_name => "OPENSTACK_AUTH_URL",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/raxprivatev3_access_key_id",
  :display_name => "RACKSPACE_PRIVATEV3_ACCESS_KEY_ID",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/raxprivatev3_secret_access_key",
  :display_name => "RACKSPACE_PRIVATEV3_SECRET_ACCESS_KEY",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

attribute "monkey/fog/raxprivatev3_auth_url",
  :display_name => "RACKSPACE_PRIVATEV3_AUTH_URL",
  :description => "",
  :required => "required",
  :recipes => ["monkey::update_fog_credentials"]

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
  :recipes => [
    "monkey::setup_rest_connection",
    "monkey::test_virtualmonkey_api_connection"
  ]

attribute "monkey/rest/right_email",
  :display_name => "RightScale Email",
  :description => "RightScale email address to connect to the API",
  :required => "required",
  :recipes => [
    "monkey::setup_rest_connection",
    "monkey::test_virtualmonkey_api_connection"
  ]

attribute "monkey/rest/right_acct_id",
  :display_name => "RightScale account ID",
  :description => "RightScale account ID used to connect to the API",
  :required => "required",
  :recipes => [
    "monkey::setup_rest_connection",
    "monkey::test_virtualmonkey_api_connection"
  ]

attribute "monkey/rest/right_subdomain",
  :display_name => "RightScale Subdomain",
  :description => "RightScale subdomain. Example. 'my', 'moo'",
  :required => "required",
  :recipes => [
    "monkey::setup_rest_connection",
    "monkey::test_virtualmonkey_api_connection"
  ]

attribute "monkey/rest/ssh_key",
  :display_name => "API user key",
  :description => "API user key used by rest_connection",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/ssh_pub_key",
  :display_name => "Public key of Jenkins master",
  :description => "Public key of Jenkins master that should be given access",
  :required => "optional",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/repo_url",
  :display_name => "Rest connection Repo URL",
  :description => "Git URL for checking out rest_connection project",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/repo_branch",
  :display_name => "Rest connection Repo Branch",
  :description => "Git branch for checking out rest_connection project",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/virtualmonkey/monkey_repo_url",
  :display_name => "VirtualMonkey Repo URL",
  :description => "Git repository URL for VirtualMonkey",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/monkey_repo_branch",
  :display_name => "VirtualMonkey Repo Branch",
  :description => "Git branch for VirtualMonkey project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/collateral_repo_url",
  :display_name => "Collateral Repo URL",
  :description => "Git URL for collateral project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/collateral_repo_branch",
  :display_name => "Collateral Repo Branch",
  :description => "Git branch for collateral project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/rocketmonkey/repo_url",
  :display_name => "RocketMonkey Repo URL",
  :description => "Git repository URL for RocketMonkey",
  :required => "required",
  :recipes => ["monkey::setup_rocketmonkey"]

attribute "monkey/rocketmonkey/repo_branch",
  :display_name => "RocketMonkey Repo Branch",
  :description => "Git branch for VirtualMonkey project",
  :required => "required",
  :recipes => ["monkey::setup_rocketmonkey"]
