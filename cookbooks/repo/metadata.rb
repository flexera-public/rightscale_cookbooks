maintainer       "RightScale, Inc."
maintainer_email "support@rightscale.com"
license          "Copyright RightScale, Inc. All rights reserved."
description      "Abstract cookbook for managing source code repositories."
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "12.1.0"

{'centos' => '>= 5.8', 'ubuntu' => '>= 10.04', 'redhat' => '>= 5.8'}.each_pair {|os, version| supports os , version}

depends "rightscale"
depends "repo_svn"
depends "repo_git"
depends "repo_ros"

recipe  "repo::default", "Default recipe for setup resources provided"

attribute "repo/default/provider",
  :display_name => "Repository Provider",
  :description => "Select a repository provider: repo_git for Git, repo_svn for SVN or repo_ros for Remote Object Store. Example: repo_git",
  :required => "recommended",
  :choice => ["repo_git", "repo_svn", "repo_ros"],
  :default => "repo_git",
  :recipes => ["repo::default"]

attribute "repo/default/repository",
  :display_name => "Repository Url",
  :description => "The URL of your svn or git repository where your application code will be checked out. Example: http://mysvn.net/app/ or git@github.com/whoami/project",
  :required => "recommended",
  :recipes => ["repo::default"]

attribute "repo/default/revision",
  :display_name => "Branch/Tag",
  :description => "Enter the branch of your repository you want to fetch. Example: master",
  :required => "recommended",
  :default => "master",
  :recipes => ["repo::default"]

# SVN
attribute "repo/default/svn_username",
  :display_name => "SVN username",
  :description => "Username for SVN repository. Example: myusername",
  :required => "optional",
  :default => "",
  :recipes => ["repo::default"]

attribute "repo/default/svn_password",
  :display_name => "SVN password",
  :description => "Password for SVN repository. Example: mypassword",
  :required => "optional",
  :default => "",
  :recipes => ["repo::default"]

# GIT
attribute "repo/default/git_ssh_key",
  :display_name => "Git SSH Key",
  :description => "The private SSH key of the git repository. Example: key:mykey",
  :default => "",
  :required => "recommended",
  :recipes => ["repo::default"]

# ROS
attribute "repo/default/storage_account_provider",
  :display_name => "ROS Storage Account Provider",
  :description => "Location where the source file is saved. Used to pull source from Remote Object Stores. Example: s3",
  :required => "optional",
  :choice => [
    "s3",
    "cloudfiles",
    "cloudfilesuk",
    "SoftLayer_Dallas",
    "SoftLayer_Singapore",
    "SoftLayer_Amsterdam"
  ],
  :recipes => ["repo::default"]

attribute "repo/default/storage_account_id",
  :display_name => "ROS Storage Account ID",
  :description => "Cloud storage account ID required to access specified cloud storage location. For Amazon S3, use your Amazon access key ID (e.g., cred:AWS_ACCESS_KEY_ID). For Rackspace Cloud Files, use your Rackspace login username.  Example: cred:RACKSPACE_USERNAME",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/storage_account_secret",
  :display_name => "ROS Storage Account Secret",
  :description => "Cloud storage account secret required to access specified cloud storage location. For Amazon S3, use your AWS secret access key (e.g., cred:AWS_SECRET_ACCESS_KEY). For Rackspace Cloud Files, use your Rackspace account API key.  Example: cred:RACKSPACE_AUTH_KEY",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/container",
  :display_name => "ROS Container",
  :description => "The cloud storage location where source project repo is located. For Amazon S3, use the bucket name. For Rackspace Cloud Files, use the container name. Example: mycontainer",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/prefix",
  :display_name => "ROS Prefix",
  :description => "Filename of required source repository archive. Example: source.tar.gz",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/perform_action",
  :display_name => "Action",
  :description => "Choose the pull action which will be performed, 'pull'- standard repo pull, 'capistrano_pull' standard pull and then capistrano deployment style will be applied. Example: pull",
  :choice => [ "pull", "capistrano_pull" ],
  :default => "pull",
  :required => "optional",
  :recipes => ["repo::default"]

attribute "repo/default/destination",
  :display_name => "Project App root",
  :description => "Destination location path for project repo. Example: /home/webapps",
  :default => "/home/webapps",
  :required => "optional",
  :recipes => ["repo::default"]
