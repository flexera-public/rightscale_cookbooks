name             "monkey"
maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Installs/Configures Virtual Monkey"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "jenkins"

recipe "monkey::setup_git",
  "Setup Git configuration for virtualmonkey."
recipe "monkey::setup_rest_connection",
  "Setup the rest_connection library."
recipe "monkey::setup_virtualmonkey",
  "Setup virtualmonkey."
recipe "monkey::setup_rocketmonkey",
  "Setup rocketmonkey."
recipe "monkey::update_fog_credentials",
  "Setup or update existing credentials for fog configuration."
recipe "monkey::setup_test_config",
  "Setup test specific configuration."

{
  :aws_access_key_id => [
    "AWS_ACCESS_KEY_ID",
    "Access Key ID for AWS"
  ],
  :aws_secret_access_key => [
    "AWS_SECRET_ACCESS_KEY",
    "Secret Access Key for AWS"
  ],
  :aws_publish_key => [
    "AWS_PUBLISH_KEY",
    "Access Key ID for AWS Publish Account"
  ],
  :aws_publish_secret_key => [
    "AWS_PUBLISH_SECRET_KEY",
    "Secret Access Key for AWS Publish Account"
  ],
  :aws_access_key_id_test => [
    "AWS_ACCESS_KEY_ID_TEST_ACCT",
    "Access Key ID for AWS Test Account"
  ],
  :aws_secret_access_key_test => [
    "AWS_SECRET_ACCESS_KEY_TEST_ACCT",
    "Secret Access Key for AWS Test Account"
  ],
  :aws_access_key_id_rstemp => [
    "AWS_ACCESS_KEY_ID_RSTEMP",
    "Access Key ID for AWS RS ServerTemplates Account"
  ],
  :aws_secret_access_key_rstemp => [
    "AWS_SECRET_ACCESS_KEY_RSTEMP",
    "Secret Access Key for the AWS RS ServerTemplates Account"
  ],
  :rackspace_api_key => [
    "RACKSPACE_API_KEY",
    "API Key for Rackspace"
  ],
  :rackspace_username => [
    "RACKSPACE_USERNAME",
    "Username for Rackspace"
  ],
  :rackspace_api_uk_key_test => [
    "RACKSPACE_API_UK_KEY_TEST",
    "API Key for Rackspace UK Test Account"
  ],
  :rackspace_uk_username_test => [
    "RACKSPACE_UK_USERNAME_TEST",
    "Username for Rackspace UK Test Account"
  ],
  :softlayer_api_key => [
    "SOFTLAYER_SECRET_ACCESS_KEY",
    "API Key for Softlayer"
  ],
  :softlayer_username => [
    "SOFTLAYER_ACCESS_KEY_ID",
    "Username for Softlayer"
  ],
  :softlayer_auth_url => [
    "SOFTLAYER_AUTH_URL",
    "Auth URL for Softlayer"
  ],
  :rackspace_managed_auth_key => [
    "RACKSPACE_MANAGED_AUTH_KEY_US_TEST",
    "Auth Key for Rackspace Managed US Test Account"
  ],
  :rackspace_managed_username => [
    "RACKSPACE_MANAGED_USERNAME_US_TEST",
    "Username for Rackspace Managed US Test Account"
  ],
  :rackspace_managed_uk_auth_key => [
    "RACKSPACE_MANAGED_AUTH_KEY_UK_TEST",
    "Auth Key for Rackspace Managed UK Test Account"
  ],
  :rackspace_managed_uk_username => [
    "RACKSPACE_MANAGED_USERNAME_UK_TEST",
    "Username for Rackspace Managed UK Test Account"
  ],
  :rackspace_auth_url_uk_test => [
    "RACKSPACE_AUTH_URL_UK_TEST",
    "Auth URL for Rackspace UK Test Account"
  ],
  :google_access_key_id => [
    "GC_ACCESS_KEY_ID",
    "Access Key ID for Google"
  ],
  :google_secret_access_key => [
    "GC_SECRET_ACCESS_KEY",
    "Secret Access Key for Google"
  ],
  :azure_access_key_id => [
    "AZURE_ACCESS_KEY_ID",
    "Access Key ID for Azure"
  ],
  :azure_secret_access_key => [
    "AZURE_SECRET_ACCESS_KEY",
    "Secret Access Key for Azure"
  ],
  :openstack_access_key_id => [
    "OPENSTACK_FOLSOM_ACCESS_KEY_ID",
    "Access Key ID for Openstack Folsom"
  ],
  :openstack_secret_access_key => [
    "OPENSTACK_FOLSOM_SECRET_ACCESS_KEY",
    "Secret Access Key for Openstack Folsom"
  ],
  :openstack_auth_url => [
    "OPENSTACK_AUTH_URL",
    "Auth URL for Openstack Folsom"
  ],
  :raxprivatev3_access_key_id => [
    "RACKSPACE_PRIVATEV3_ACCESS_KEY_ID",
    "Access Key ID for Rackspace Private V3"
  ],
  :raxprivatev3_secret_access_key => [
    "RACKSPACE_PRIVATEV3_SECRET_ACCESS_KEY",
    "Secret Access Key for Rackspace Private V3"
  ],
  :raxprivatev3_auth_url => [
    "RACKSPACE_PRIVATEV3_AUTH_URL",
    "Auth URL for Rackspace Private V3"
  ],
  :hp_access_key_id => [
    "HP_ACCESS_KEY_ID",
    "Access Key ID for HP"
  ],
  :hp_secret_access_key => [
    "HP_SECRET_ACCESS_KEY",
    "Secret Access Key for HP"
  ],
  :hp_auth_url => [
    "HP_AUTH_URL",
    "Auth URL for HP"
  ],
  :s3_bucket => [
    "S3_BUCKET_NAME",
    "The Name of the S3 Bucket to Store Monkey Reports"
  ],
}.each do |attribute_name, value|
  display_name, description = value

  attribute "monkey/fog/#{attribute_name}",
    :display_name => display_name,
    :description => description,
    :required => "required",
    :recipes => ["monkey::update_fog_credentials"]
end

attribute "monkey/git/user",
  :display_name => "Git Username",
  :description =>
    "Git Username to be used with github",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/git/email",
  :display_name => "Git Email",
  :description =>
    "Git email address to be used with github",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/git/ssh_key",
  :display_name => "SSH key for Git",
  :description =>
    "SSH key for using with Git",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/git/host_name",
  :display_name => "Git Hostname",
  :description =>
    "Git Hostname for adding to ssh config",
  :required => "required",
  :recipes => ["monkey::setup_git"]

attribute "monkey/rest/right_passwd",
  :display_name => "RightScale password",
  :description =>
    "RightScale password to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/right_email",
  :display_name => "RightScale Email",
  :description =>
    "RightScale email address to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/right_acct_id",
  :display_name => "RightScale account ID",
  :description =>
    "RightScale account ID used to connect to the API",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/right_subdomain",
  :display_name => "RightScale Subdomain",
  :description =>
    "RightScale subdomain. Example. 'my', 'moo.test'",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/ssh_key",
  :display_name => "API user key",
  :description =>
    "API user key used by rest_connection",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/ssh_pub_key",
  :display_name => "Public key of Jenkins master",
  :description =>
    "Public key of Jenkins master that should be given access",
  :required => "optional",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/repo_url",
  :display_name => "Rest connection Repo URL",
  :description =>
    "Git URL for checking out rest_connection project",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/repo_branch",
  :display_name => "Rest connection Repo Branch",
  :description =>
    "Git branch for checking out rest_connection project",
  :required => "required",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/azure_hack_on",
  :display_name => "Azure Hack ON/OFF",
  :description =>
    "Whether to enable/disable Azure retry hack",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "true",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/azure_hack_retry_count",
  :display_name => "Azure Hack Retry Count",
  :description =>
    "Number of retries for Azure launch failures. Example: 5",
  :required => "optional",
  :default => "5",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/azure_hack_sleep_seconds",
  :display_name => "Azure Hack Sleep Seconds",
  :description =>
    "Number of seconds to sleep between attempts on relaunches",
  :required => "optional",
  :default => "60",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/rest/api_logging",
  :display_name => "API Logging",
  :description =>
    "Whether to enable/disable API logging",
  :required => "optional",
  :choice => ["true", "false"],
  :default => "false",
  :recipes => ["monkey::setup_rest_connection"]

attribute "monkey/test_config/knife_pem_key",
  :display_name => "Knife PEM Key",
  :description =>
    "The PEM key used by the knife commands to communicate with hosted" +
    " chef server",
  :required => "required",
  :recipes => ["monkey::setup_test_config"]

attribute "monkey/virtualmonkey/monkey_repo_url",
  :display_name => "VirtualMonkey Repo URL",
  :description =>
    "Git repository URL for VirtualMonkey",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/monkey_repo_branch",
  :display_name => "VirtualMonkey Repo Branch",
  :description =>
    "Git branch for VirtualMonkey",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/collateral_repo_url",
  :display_name => "Collateral Repo URL",
  :description =>
    "Git URL for collateral project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/collateral_repo_branch",
  :display_name => "Collateral Repo Branch",
  :description =>
    "Git branch for collateral project",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/right_api_objects_repo_url",
  :display_name => "Right API Objects Repo URL",
  :description =>
    "Git repository URL for Right API Objects",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/right_api_objects_repo_branch",
  :display_name => "Right API Objects Repo Branch",
  :description =>
    "Git branch for Right API Objects",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/virtualmonkey/windows_admin_password",
  :display_name => "Windows Administrator Password",
  :description =>
    "The Administrator password for connecting to Windows servers",
  :required => "required",
  :recipes => ["monkey::setup_virtualmonkey"]

attribute "monkey/rocketmonkey/repo_url",
  :display_name => "RocketMonkey Repo URL",
  :description =>
    "Git repository URL for RocketMonkey",
  :required => "required",
  :recipes => ["monkey::setup_rocketmonkey"]

attribute "monkey/rocketmonkey/repo_branch",
  :display_name => "RocketMonkey Repo Branch",
  :description =>
    "Git branch for VirtualMonkey project",
  :required => "required",
  :recipes => ["monkey::setup_rocketmonkey"]

attribute "monkey/test/smtp_username",
  :display_name => "SMTP Username",
  :description =>
    "The SMTP username for lamp's check smtp test",
  :required => "required",
  :recipes => ["monkey::setup_test_config"]

attribute "monkey/test/smtp_password",
  :display_name => "SMTP Password",
  :description =>
    "The SMTP password for lamp's check smtp test",
  :required => "required",
  :recipes => ["monkey::setup_test_config"]
