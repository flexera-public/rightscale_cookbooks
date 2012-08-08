maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Abstract cookbook for managing source code repositories."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "13.1.0"

supports "centos", "~> 5.8"
supports "redhat", "~> 5.8"
supports "ubuntu", "~> 10.04.0"

depends "rightscale"
depends "repo_svn"
depends "repo_git"
depends "repo_ros"
depends "repo_ftp"
depends "repo_rsync"

recipe  "repo::default", "Default recipe to setup provided resources."


attribute "repo/default/provider",
  :display_name => "Repository Provider",
  :description => "Specify where the application code should be checked out from. Example: repo_git",
  :required => "recommended",
  :choice => ["repo_git", "repo_svn", "repo_ros", "repo_ftp", "repo_rsync"],
  :default => "repo_git",
  :recipes => ["repo::default"]

attribute "repo/default/repository",
  :display_name => "Repository URL",
  :description => "The URL that points to the location of the repository that contains the application code. Specify a read-only URL. Example: http://mysvn.net/app/ or git://github.com/username/myapp.git",
  :required => "recommended",
  :recipes => ["repo::default"]

attribute "repo/default/revision",
  :display_name => "Repository Branch/Tag/Commit",
  :description => "The specific branch, tag, or commit (SHA) of the specified Git/Subversion repository that the application code will be retrieved from. For Git repositories, use 'master' to retrieve the master branch from the repository. Example: mybranch",
  :required => "recommended",
  :default => "master",
  :recipes => ["repo::default"]

attribute "repo/default/account",
  :display_name => "Account name",
  :description => "The account name (i.e. username, ID) that is required to access files in the specified location. Example: cred:RACKSPACE_USERNAME",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/credential",
  :display_name => "Account credential",
  :description => "A valid credential (i.e. password, SSH key, account secret) to access files in the specified location. Example: cred:RACKSPACE_AUTH_KEY",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/perform_action",
  :display_name => "Action",
  :description => "Specify how the application code will be pulled from the specified repository. 'pull'- standard repository pull, 'capistrano_pull' standard repository pull plus a capistrano deployment style is applied. Example: pull",
  :choice => [ "pull", "capistrano_pull" ],
  :default => "pull",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/destination",
  :display_name => "Project App root",
  :description => "The destination location where the application code will be placed on the local instance. If you want the application code to be placed in the root directory, use a forward slash (/) otherwise you will need to specify the full path (e.g. /path/to/code). If set to 'ignore' the default location (/home/webapp) will be used. The 'Application Name' input is used to name the destination folder into which the application code will be placed. Apache and PHP will look for the application in the specified path. Example: /home/webapps",
  :default => "/home/webapps",
  :required => "optional",
  :recipes => ["repo::default"]

# ROS
#
attribute "repo/default/storage_account_provider",
  :display_name => "ROS Storage Account Provider",
  :description => "The Remote Object Storage (ROS) service where the tarball of the application code will be retrieved from. Example: s3",
  :required => "optional",
  :choice => [
    "s3",
    "cloudfiles",
    "cloudfilesuk",
    "google",
    "azure",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => ["repo::default"]

attribute "repo/default/container",
  :display_name => "ROS Container",
  :description => "The name of the ROS container where a tarball of the application code will be retrieved from. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name. Example: mycontainer",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/prefix",
  :display_name => "ROS Prefix",
  :description => "The prefix that will be used to locate the correct tarball of the application. For example, if you're using 'myapp.tgz' specify 'myapp' as the ROS Prefix.",
  :required => "optional",
  :recipes => ["repo::default"]
