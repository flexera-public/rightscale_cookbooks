# RightScale Repo Cookbook

## DESCRIPTION:

This cookbook provides abstract 'repo' resource for managing code download from
Git, Subversion or Remote Object Store code repositories.

## REQUIREMENTS:

* Requires a virtual machine launched from a RightScale-managed RightImage.
* ROS implementation requires the 'rightscale::install_tools' recipe

## COOKBOOKS DEPENDENCIES:

Please see `metadata.rb` file for the latest dependencies.

* `rightscale`
* `repo_svn`
* `repo_git`
* `repo_ros`
* `repo_rsync`
* `repo_ftp`

cookbooks must be present in ServerTemplate repository.

## KNOWN LIMITATIONS:

There are no known limitations.

## SETUP/USAGE:

* Place repo::default recipe into your runlist to setup the repo resource. When
  using a RightScale ServerTemplate, this will also automatically add the
  required attributes to your ServerTemplate inputs.
* Add 'repo' resource call in your recipe and provide all required parameters.
* Add 'destination' and 'action' attributes to your 'repo' resource.
* Set desired action for your 'repo' resource
  It can be :pull or :capistrano_pull
  :pull - perform basic 'repo' action, just pulling your code from remote repo.
  :capistrano_pull - performs pulling and backup of your code.
  For code implementation examples look at **LWRPs** section of this README.

## DETAILS:

### General

This cookbook is intended to be used in conjunction with cookbooks that contain
Lightweight Providers which implement the 'repo' interface. See the RightScale
repo_git cookbook for an example.

### Attributes

All attributes in this cookbook are generally used to assign values for
corresponding `repo` LWRP attribute.

All attributes in this cookbook have inputs except **Additional capistrano
attributes** which are used internally in recipes.

##### Common attributes

* `node[:repo][:default][:destination]` - Path to where project repo will
  be pulled. Example: "/tmp/repo"
* `node[:repo][:default][:repository]` - The URL of your svn or git
  repository where your application code will be checked out. Or name of the ROS
  container if repo_ros LWRP is chosen. For Amazon S3, use the bucket name.
  For Rackspace Cloud Files, use the container name.
* `node[:repo][:default][:revision]` - Remote repo Branch, Tag or
  revision. The default is "HEAD".
* `node[:repo][:default][:provider]` - A repository provider:
  `repo_git` for Git, `repo_svn` for Subversion or
  `repo_ros` for Remote Object Store. The default is "repo_git".
* `node[:repo][:default][:perform_action]` - The type pull action which
  will be performed, 'pull'- standard repo pull, 'capistrano_pull' standard pull
  and then capistrano deployment style will be applied. Default is: "pull".
* `node[:repo][:default][:account]` - The account name (i.e. username, ID)
  that is required to access files in the specified location.
* `node[:repo][:default][:credential]` - A valid credential (i.e. password,
  SSH key, account secret) to access files in the specified location.


##### ROS attributes

* `node[:repo][:default][:storage_account_provider]` - Location where the
  source file is saved. Used by recipes to download from Amazon S3, Rackspace,
  Google, Azure, SoftLayer, Swift and Cloud Files. Default is: "S3".
* `node[:repo][:default][:endpoint]` - Is used to override the default
  endpoint or for generic storage clouds such as Swift. Example:
  "http://endpoint_ip:5000/v2.0/tokens"
* `node[:repo][:default][:prefix]` - Filename of required source
  repository archive. Example: "source.tar.gz".

##### Additional capistrano attributes

* `node[:repo][:default][:environment]` - A hash of the form
  `{"ENV_VARIABLE"=>"VALUE"}` ({})
* `node[:repo][:default][:symlinks]` - An array of paths, relative to app
  root, to be removed from a checkout before symlinking. Default is:({})
* `node[:repo][:default][:purge_before_symlink]` - An array of paths,
  relative to app root, to be removed from a checkout before symlinking. Default
  is: %w{}
* `node[:repo][:default][:create_dirs_before_symlink]` - Directories to
  create before symlinking. Runs after purge_before_symlink. Default is: %w{}

### Definitions:

__repo_capistranize__

Definition used to create Capistrano style project deployment.
For more information about capistrano see [The Deploy Strategies][wiki].

[wiki]: http://wiki.opscode.com/display/chef/Deploy+Resource#DeployResource-TheDeployStrategies

Parameters:

All parameters in this definition are linked to corresponding attributes.
However if you use this definition for your own purposes you can redefine them.
See example below.

* `:destination` - Receive value of corresponding attribute. See
  `node[:repo][:default][:destination]` in attributes section of this
  README.
* `:repository` - Receive value of corresponding attribute. See
  `node[:repo][:default][:repository]` in attributes section of this
  README.
* `:revision` - Receive value of corresponding attribute. See
  `node[:repo][:default][:revision]` in attributes section of this
  README.
* `:svn_username` - Receive value of corresponding attribute. See
  `node[:repo][:default][:account]` in attributes section of this
  README.
* `:svn_password` - Receive value of corresponding attribute. See
  `node[:repo][:default][:credential]` in attributes section of this
  README.
* `:app_user` - User that will be owner of created project deployment.
* `:environment` - Receive value of corresponding attribute. See
  `node[:repo][:default][:environment]` in attributes section of this
  README.
* `:create_dirs_before_symlink` - Receive value of corresponding
  attribute. See `node[:repo][:default][:create_dirs_before_symlink]` in
  attributes section of this README.
* `:purge_before_symlink` - Receive value of corresponding attribute. See
  `node[:repo][:default][:purge_before_symlink]` in attributes section of
  this README.
* `:symlinks` - Receive value of corresponding attribute. See
  `node[:repo][:default][:symlinks]` in attributes section of this
  README.
* `:scm_provider` - Receive value of corresponding attribute. See
  `node[:repo][:default][:provider]` in attributes section of this
  README.

Example:

    repo_capistranize "Source repo" do
      repository your_repository_variable
      revision revision_variable
      destination destination_variable
      app_user app_user_variable
      purge_before_symlink purge_before_symlink_variable
      create_dirs_before_symlink create_dirs_before_symlink_variable
      symlinks symlinks_variable
      scm_provider scm_provider_variable
      environment environment_variable
    end


### LWRPs:

#### Resources

This cookbook provides abstract `repo` resource. Which will be used to
call existing or user defined Light Weight repo_* providers.

Supported cookbooks are repo_ros, repo_git and repo_svn cookbooks. Each of them
contain implementation of corresponding repo_* Light Weight Provider which can
be called using this resource.

##### Actions:

`:pull`
Standard repo pull. Your source code repository will be pulled from remote url
to specified destination.

`:capistrano_pull`
Perform standard pull and then capistrano deployment style will be applied.

##### Attributes:

These are settings used in recipes and templates. Default values should be
noted.

Note: Only "internal" cookbook attributes are described here. Descriptions of
attributes which have inputs can be found in the metadata.rb cookbook file.

* `destination` - Path to where project repo will be pulled
* `revision` - Remote repo Branch or revision
* `account` - Account name
* `credential` - Account credential
* `svn_arguments` - Extra arguments passed to the subversion command
* `app_user` - System user to run the deploy as
* `purge_before_symlink` - An array of paths, relative to app root, to be
  removed from a checkout before symlinking
* `create_dirs_before_symlink` - Directories to create before symlinking.
  Runs after purge_before_symlink
* `symlinks` - A hash that maps files in the shared directory to their
  paths in the current release
* `environment` - A hash of the form {"ENV_VARIABLE"=>"VALUE"}
* `prefix` - The prefix that will be used to name/locate the backup of a
  particular code repo.
* `storage_account_provider` - Location where dump file will be saved.
  Used by dump recipes to back up to Amazon S3 or Rackspace Cloud Files.
* `unpack_source` - Unpack downloaded source or not Source file must be
  kind of tar archive Default: false

##### Usage Example:

__:pull__

    repo "default" do
      destination "/tmp/repo"
      action :pull
    end

__:capistrano\_pull__

    repo "default" do
      destination "/tmp/repo"
      action :capistrano_pull
      # owner of created repo directories
      app_user 'rightscale'
      # An array of paths, relative to app root, to be removed from a checkout
      # before symlinking
      purge_before_symlink %w{tmp}
      # A hash that maps files in the shared directory to their paths in the
      # current release
      create_dirs_before_symlink %w{log dir2}
      # A hash that maps files in the shared directory to their paths in the
      # current release
      symlinks ({})
      # A hash of the form {'ENV_VARIABLE'=>'VALUE'}
      environment ({})
    end

## LICENSE:

Copyright RightScale, Inc. All rights reserved.
All access and use subject to the RightScale Terms of Service available at
http://www.rightscale.com/terms.php and, if applicable, other agreements
such as a RightScale Master Subscription Agreement.
