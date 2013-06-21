maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Abstract cookbook for managing source code repositories."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "13.5.0"

supports "centos"
supports "redhat"
supports "ubuntu"

depends "rightscale"
depends "repo_svn"
depends "repo_git"
depends "repo_ros"
depends "repo_ftp"
depends "repo_rsync"

recipe "repo::default",
  "Sets up repo resource and provider."

attribute "repo/default/provider",
  :display_name => "Repository Provider",
  :description =>
    "Specify where the application code should be checked out from." +
    " Example: repo_git",
  :required => "recommended",
  :choice => ["repo_git", "repo_svn", "repo_ros", "repo_ftp", "repo_rsync"],
  :default => "repo_git",
  :recipes => ["repo::default"]

attribute "repo/default/repository",
  :display_name => "Repository URL/ROS Container",
  :description =>
    "The URL that points to the location of the repository" +
    " that contains the application code. Or the name of the ROS container" +
    " where a tarball of the application code will be retrieved from" +
    " if you use 'repo_ros' provider. For Amazon S3, use the bucket name." +
    " Example: mycontainer, http://mysvn.net/app/" +
    " or git://github.com/username/myapp.git",
  :required => "required",
  :recipes => ["repo::default"]

attribute "repo/default/revision",
  :display_name => "Repository Branch/Tag/Commit",
  :description =>
    "The specific branch, tag, or commit (SHA) of the specified" +
    " Git/Subversion repository that the application code will" +
    " be retrieved from. For Git repositories, use 'master'" +
    " to retrieve the master branch from the repository." +
    " For SVN repositories, use 'HEAD' to retrieve the latest changes" +
    " from the repository. Example: mybranch",
  :required => "recommended",
  :default => "master",
  :recipes => ["repo::default"]

attribute "repo/default/account",
  :display_name => "Account name",
  :description =>
    "The account name (i.e. username, ID) that is required to access files in" +
    " the specified location. This input is optional and may not be required." +
    " Example: cred:RACKSPACE_USERNAME",
  :required => "recommended",
  :recipes => ["repo::default"]

attribute "repo/default/credential",
  :display_name => "Account credential",
  :description =>
    "A valid credential (i.e. password, SSH key, account secret)" +
    " to access files in the specified location. This input is always" +
    " required for Git and Rsync but may be optional for other providers." +
    " Example: cred:RACKSPACE_AUTH_KEY",
  :required => "recommended",
  :recipes => ["repo::default"]

attribute "repo/default/endpoint",
  :display_name => "Storage Cloud Endpoint URL",
  :description =>
    "The endpoint URL for the storage cloud. This is used to override the" +
    " default endpoint or for generic storage clouds such as Swift." +
    " Example: http://endpoint_ip:5000/v2.0/tokens",
  :required => "optional",
  :default => "",
  :recipes => ["repo::default"]

attribute "repo/default/ssh_host_key",
  :display_name => "Known hosts ssh key",
  :description =>
    "A valid SSH key which will be appended to /root/.ssh/known_hosts file." +
    " This input will allow to verify the destination host, by comparing its" +
    " IP,FQDN, SSH-RSA with the record in /root/.ssh/known_hosts file." +
    " Use this input if you want to improve security" +
    " and for MiTM attacks prevention. Example: cred:SSH_KNOWN_HOST_KEY.",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/perform_action",
  :display_name => "Action",
  :description =>
    "Specify how the application code will be pulled from" +
    " the specified repository. 'pull'- standard repository pull," +
    " 'capistrano_pull' standard repository pull plus a capistrano" +
    " deployment style is applied. Example: pull",
  :choice => ["pull", "capistrano_pull"],
  :default => "pull",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/destination",
  :display_name => "Project App root",
  :description =>
    "The destination location where the application code will be placed" +
    " on the local instance. If you want the application code" +
    " to be placed in the root directory, use a forward slash (/)" +
    " otherwise you will need to specify the full path (e.g. /path/to/code)." +
    " Example: /home/webapps",
  :default => "/home/webapps",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/storage_account_provider",
  :display_name => "ROS Storage Account Provider",
  :description =>
    "The Remote Object Storage (ROS) service where the tarball" +
    " of the application code will be retrieved from. Example: s3",
  :required => "optional",
  :choice => [
    "s3",
    "cloudfiles",
    "cloudfilesuk",
    "google",
    "azure",
    "swift",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => ["repo::default"]

attribute "repo/default/prefix",
  :display_name => "ROS Prefix",
  :description =>
    "The prefix that will be used to locate the correct tarball of" +
    " the application. For example, if you're using 'myapp.tgz'" +
    " specify 'myapp' as the ROS Prefix. Example: myapp",
  :required => "optional",
  :recipes => ["repo::default"]
